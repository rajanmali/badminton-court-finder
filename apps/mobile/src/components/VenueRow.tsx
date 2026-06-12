import type { VenueListItem } from '@smash/api-client';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { formatPriceCents } from '../utils/pricing';

interface Props {
  venue: VenueListItem;
  onPress: () => void;
}

export function VenueRow({ venue, onPress }: Props) {
  return (
    <TouchableOpacity style={styles.row} onPress={onPress} activeOpacity={0.7}>
      <View style={styles.main}>
        <View style={styles.nameRow}>
          <Text style={styles.name} numberOfLines={1}>
            {venue.name}
          </Text>
          {venue.dedicatedBadminton && (
            <View style={styles.badge}>
              <Text style={styles.badgeText}>Dedicated</Text>
            </View>
          )}
        </View>
        <Text style={styles.suburb}>{venue.suburb}</Text>
      </View>
      <View style={styles.meta}>
        <Text style={styles.price}>From {formatPriceCents(venue.priceFrom)}</Text>
        <Text style={styles.courts}>
          {venue.courtCount} {venue.courtCount === 1 ? 'court' : 'courts'}
        </Text>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: '#fff',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e0e0e0',
  },
  main: {
    flex: 1,
    marginRight: 12,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 2,
  },
  name: {
    fontSize: 15,
    fontWeight: '600',
    color: '#111',
    flexShrink: 1,
  },
  badge: {
    backgroundColor: '#00C853',
    borderRadius: 4,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  badgeText: {
    fontSize: 10,
    fontWeight: '700',
    color: '#fff',
    letterSpacing: 0.3,
  },
  suburb: {
    fontSize: 13,
    color: '#666',
  },
  meta: {
    alignItems: 'flex-end',
  },
  price: {
    fontSize: 13,
    fontWeight: '600',
    color: '#111',
    marginBottom: 2,
  },
  courts: {
    fontSize: 12,
    color: '#888',
  },
});
