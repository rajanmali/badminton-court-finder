import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import { StyleSheet, Text, View } from 'react-native';
import type { RootStackParamList } from '../navigation/RootNavigator';

type Props = NativeStackScreenProps<RootStackParamList, 'VenueDetail'>;

export function VenueDetailScreen({ route }: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.placeholder}>
        Venue detail for {route.params.venueId} — coming in #10
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#fff',
  },
  placeholder: {
    fontSize: 16,
    color: '#666',
  },
});
