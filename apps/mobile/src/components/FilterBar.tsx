import { ScrollView, StyleSheet, Switch, Text, TouchableOpacity, View } from 'react-native';
import type { FilterState } from '../utils/filters';

interface Props {
  filters: FilterState;
  onChange: (patch: Partial<FilterState>) => void;
  locationDenied: boolean;
}

const RADIUS_OPTIONS: Array<{ label: string; value: number | null }> = [
  { label: 'Any', value: null },
  { label: '5 km', value: 5 },
  { label: '10 km', value: 10 },
  { label: '20 km', value: 20 },
];

const PRICE_OPTIONS: Array<{ label: string; value: number | null }> = [
  { label: 'Any', value: null },
  { label: '≤$30', value: 3000 },
  { label: '≤$35', value: 3500 },
  { label: '≤$40', value: 4000 },
];

export function FilterBar({ filters, onChange, locationDenied }: Props) {
  return (
    <View style={styles.container}>
      {/* Distance */}
      <View style={styles.row}>
        <Text style={styles.label}>Distance</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips}>
          {RADIUS_OPTIONS.map((opt) => {
            const active = filters.radiusKm === opt.value;
            const disabled = locationDenied && opt.value !== null;
            return (
              <TouchableOpacity
                key={String(opt.value)}
                style={[styles.chip, active && styles.chipActive, disabled && styles.chipDisabled]}
                onPress={() => !disabled && onChange({ radiusKm: opt.value })}
                activeOpacity={disabled ? 1 : 0.7}
              >
                <Text style={[styles.chipText, active && styles.chipTextActive, disabled && styles.chipTextDisabled]}>
                  {opt.label}
                </Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>
      {locationDenied && (
        <Text style={styles.locationHint}>Enable location to filter by distance</Text>
      )}

      {/* Max price */}
      <View style={styles.row}>
        <Text style={styles.label}>Max price</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips}>
          {PRICE_OPTIONS.map((opt) => {
            const active = filters.maxPriceCents === opt.value;
            return (
              <TouchableOpacity
                key={String(opt.value)}
                style={[styles.chip, active && styles.chipActive]}
                onPress={() => onChange({ maxPriceCents: opt.value })}
                activeOpacity={0.7}
              >
                <Text style={[styles.chipText, active && styles.chipTextActive]}>{opt.label}</Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>

      {/* Dedicated toggle */}
      <View style={[styles.row, styles.toggleRow]}>
        <Text style={styles.label}>Dedicated courts only</Text>
        <Switch
          value={filters.dedicatedOnly}
          onValueChange={(v) => onChange({ dedicatedOnly: v })}
          trackColor={{ true: '#00C853' }}
          thumbColor="#fff"
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f8f8f8',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e0e0e0',
    paddingBottom: 8,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 10,
    gap: 10,
  },
  toggleRow: {
    justifyContent: 'space-between',
  },
  label: {
    fontSize: 12,
    fontWeight: '600',
    color: '#555',
    width: 60,
    flexShrink: 0,
  },
  chips: {
    flexDirection: 'row',
    gap: 6,
  },
  chip: {
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#ccc',
    backgroundColor: '#fff',
  },
  chipActive: {
    backgroundColor: '#00C853',
    borderColor: '#00C853',
  },
  chipDisabled: {
    backgroundColor: '#f0f0f0',
    borderColor: '#e0e0e0',
  },
  chipText: {
    fontSize: 13,
    color: '#333',
  },
  chipTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  chipTextDisabled: {
    color: '#bbb',
  },
  locationHint: {
    fontSize: 11,
    color: '#f57c00',
    paddingHorizontal: 16,
    paddingTop: 4,
  },
});
