import { getVenues } from '@smash/api-client';
import { useQuery } from '@tanstack/react-query';
import { useReducer, useState } from 'react';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import {
  ActivityIndicator,
  FlatList,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import type { RootStackParamList } from '../navigation/RootNavigator';
import { VenueRow } from '../components/VenueRow';
import { FilterBar } from '../components/FilterBar';
import { VenueMap } from '../components/VenueMap';
import { ViewToggle } from '../components/ViewToggle';
import { useLocation } from '../hooks/useLocation';
import { applyFilters, DEFAULT_FILTERS, type FilterState } from '../utils/filters';

type Props = NativeStackScreenProps<RootStackParamList, 'VenueList'>;

function filterReducer(state: FilterState, patch: Partial<FilterState>): FilterState {
  return { ...state, ...patch };
}

export function VenueListScreen({ navigation }: Props) {
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');
  const [filters, dispatch] = useReducer(filterReducer, DEFAULT_FILTERS);
  const location = useLocation();

  const { data, isPending, isError, error } = useQuery({
    queryKey: ['venues'],
    queryFn: () => getVenues(),
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
        <Text style={styles.errorTitle}>Could not load venues</Text>
        <Text style={styles.errorDetail}>{(error as Error).message}</Text>
      </View>
    );
  }

  const filtered = applyFilters(data.venues, filters, location.coords);

  const goToVenue = (venueId: string, venueName: string) =>
    navigation.navigate('VenueDetail', { venueId, venueName });

  return (
    <View style={styles.screen}>
      <ViewToggle mode={viewMode} onChange={setViewMode} />
      <FilterBar
        filters={filters}
        onChange={dispatch}
        locationDenied={location.permissionDenied}
      />
      {viewMode === 'list' ? (
        <FlatList
          data={filtered}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <VenueRow
              venue={item}
              onPress={() => goToVenue(item.id, item.name)}
            />
          )}
          contentContainerStyle={filtered.length === 0 ? styles.emptyContainer : undefined}
          ListEmptyComponent={<Text style={styles.empty}>No venues match your filters.</Text>}
        />
      ) : (
        <VenueMap
          venues={filtered}
          userCoords={location.coords}
          onVenuePress={goToVenue}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#fff',
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#fff',
  },
  errorTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  errorDetail: {
    fontSize: 13,
    color: '#888',
    textAlign: 'center',
  },
  emptyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  empty: {
    fontSize: 15,
    color: '#888',
  },
});
