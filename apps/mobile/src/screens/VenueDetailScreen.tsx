import { getVenue } from '@smash/api-client';
import { useQuery } from '@tanstack/react-query';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import {
  ActivityIndicator,
  Linking,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import type { RootStackParamList } from '../navigation/RootNavigator';
import { formatPriceCents } from '../utils/pricing';
import { dayLabel, formatDays, formatTime } from '../utils/datetime';
import { getBookingAction } from '../utils/booking';
import type { RateCard, OpeningHours } from '@smash/api-client';

type Props = NativeStackScreenProps<RootStackParamList, 'VenueDetail'>;

export function VenueDetailScreen({ route }: Props) {
  const { venueId } = route.params;

  const { data, isPending, isError, error } = useQuery({
    queryKey: ['venue', venueId],
    queryFn: () => getVenue(venueId),
  });

  if (isPending) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#00C853" />
      </View>
    );
  }

  if (isError) {
    return (
      <View style={styles.centered}>
        <Text style={styles.errorTitle}>Could not load venue</Text>
        <Text style={styles.errorDetail}>{(error as Error).message}</Text>
      </View>
    );
  }

  const { venue } = data;

  return (
    <ScrollView style={styles.scroll} contentContainerStyle={styles.content}>
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.titleRow}>
          <Text style={styles.name}>{venue.name}</Text>
          {venue.dedicatedBadminton && (
            <View style={styles.badge}>
              <Text style={styles.badgeText}>Dedicated</Text>
            </View>
          )}
        </View>
        <Text style={styles.suburb}>{venue.suburb}</Text>
        {venue.address ? <Text style={styles.address}>{venue.address}</Text> : null}
        <Text style={styles.meta}>
          {venue.courtCount} {venue.courtCount === 1 ? 'court' : 'courts'}
          {venue.priceFrom !== null ? `  ·  From ${formatPriceCents(venue.priceFrom)}` : ''}
        </Text>
      </View>

      {/* Rate cards */}
      <Section title="Court hire rates">
        {venue.rateCards.length === 0 ? (
          <Text style={styles.empty}>Rates not listed</Text>
        ) : (
          venue.rateCards.map((rc: RateCard) => <RateRow key={rc.id} rc={rc} />)
        )}
      </Section>

      {/* Opening hours */}
      <Section title="Opening hours">
        {venue.openingHours.length === 0 ? (
          <Text style={styles.empty}>Hours not listed</Text>
        ) : (
          ALL_DAYS.map((dow) => {
            const h = venue.openingHours.find((o: OpeningHours) => o.dayOfWeek === dow);
            return <HoursRow key={dow} dow={dow} h={h ?? null} />;
          })
        )}
      </Section>

      {/* Book / contact CTA */}
      <BookingCTA venue={venue} />
    </ScrollView>
  );
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {children}
    </View>
  );
}

function RateRow({ rc }: { rc: RateCard }) {
  return (
    <View style={styles.rateRow}>
      <View style={styles.rateLeft}>
        <Text style={styles.rateLabel}>{rc.label}</Text>
        <Text style={styles.rateMeta}>
          {formatDays(rc.daysApply)}
          {rc.timeRangeStart ? `  ·  ${formatTime(rc.timeRangeStart)}–${formatTime(rc.timeRangeEnd)}` : ''}
        </Text>
        {rc.notes ? <Text style={styles.rateNotes}>{rc.notes}</Text> : null}
      </View>
      <Text style={styles.ratePrice}>{formatPriceCents(rc.priceCents)}</Text>
    </View>
  );
}

// dayOfWeek 0=Sun per schema; display Mon–Sun order
const ALL_DAYS = [1, 2, 3, 4, 5, 6, 0];

function HoursRow({ dow, h }: { dow: number; h: OpeningHours | null }) {
  const closed = !h || h.isClosed;
  return (
    <View style={styles.hoursRow}>
      <Text style={styles.hoursDay}>{dayLabel(dow)}</Text>
      {closed ? (
        <Text style={styles.hoursClosed}>Closed</Text>
      ) : (
        <Text style={styles.hoursTime}>
          {formatTime(h!.openTime)} – {formatTime(h!.closeTime)}
        </Text>
      )}
    </View>
  );
}

function BookingCTA({ venue }: { venue: { bookingUrl: string; phone: string | null; email: string | null } }) {
  const action = getBookingAction(venue);
  if (action.type === 'none') return null;
  return (
    <TouchableOpacity
      style={styles.bookBtn}
      activeOpacity={0.8}
      onPress={() => Linking.openURL(action.href)}
    >
      <Text style={styles.bookBtnText}>{action.label}</Text>
    </TouchableOpacity>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: '#fff' },
  content: { paddingBottom: 32 },
  centered: {
    flex: 1, alignItems: 'center', justifyContent: 'center',
    padding: 24, backgroundColor: '#fff',
  },
  errorTitle: { fontSize: 16, fontWeight: '600', color: '#333', marginBottom: 8 },
  errorDetail: { fontSize: 13, color: '#888', textAlign: 'center' },

  header: { padding: 20, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#e0e0e0' },
  titleRow: { flexDirection: 'row', alignItems: 'center', gap: 8, flexWrap: 'wrap', marginBottom: 4 },
  name: { fontSize: 20, fontWeight: '700', color: '#111', flexShrink: 1 },
  badge: { backgroundColor: '#00C853', borderRadius: 4, paddingHorizontal: 8, paddingVertical: 3 },
  badgeText: { fontSize: 11, fontWeight: '700', color: '#fff', letterSpacing: 0.3 },
  suburb: { fontSize: 15, color: '#555', marginBottom: 2 },
  address: { fontSize: 13, color: '#888', marginBottom: 4 },
  meta: { fontSize: 14, color: '#444', marginTop: 4 },

  section: { paddingHorizontal: 20, paddingTop: 20 },
  sectionTitle: { fontSize: 13, fontWeight: '700', color: '#888', textTransform: 'uppercase', letterSpacing: 0.8, marginBottom: 12 },
  empty: { fontSize: 14, color: '#aaa' },

  rateRow: { flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between', paddingVertical: 10, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#f0f0f0' },
  rateLeft: { flex: 1, marginRight: 16 },
  rateLabel: { fontSize: 15, fontWeight: '600', color: '#111', marginBottom: 2 },
  rateMeta: { fontSize: 12, color: '#888' },
  rateNotes: { fontSize: 11, color: '#aaa', marginTop: 2 },
  ratePrice: { fontSize: 15, fontWeight: '700', color: '#00C853' },

  hoursRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 8, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#f0f0f0' },
  hoursDay: { fontSize: 14, color: '#333', width: 40 },
  hoursTime: { fontSize: 14, color: '#111' },
  hoursClosed: { fontSize: 14, color: '#aaa' },

  bookBtn: { marginHorizontal: 20, marginTop: 28, backgroundColor: '#00C853', borderRadius: 10, paddingVertical: 16, alignItems: 'center' },
  bookBtnText: { fontSize: 16, fontWeight: '700', color: '#fff', letterSpacing: 0.3 },
});
