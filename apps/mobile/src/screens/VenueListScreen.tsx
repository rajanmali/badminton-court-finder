import { getVenues } from '@smash/api-client';
import { useQuery } from '@tanstack/react-query';
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

type Props = NativeStackScreenProps<RootStackParamList, 'VenueList'>;

export function VenueListScreen({ navigation }: Props) {
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

  return (
    <FlatList
      data={data.venues}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <VenueRow
          venue={item}
          onPress={() =>
            navigation.navigate('VenueDetail', {
              venueId: item.id,
              venueName: item.name,
            })
          }
        />
      )}
      contentContainerStyle={data.venues.length === 0 ? styles.emptyContainer : undefined}
      ListEmptyComponent={<Text style={styles.empty}>No venues found.</Text>}
    />
  );
}

const styles = StyleSheet.create({
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
