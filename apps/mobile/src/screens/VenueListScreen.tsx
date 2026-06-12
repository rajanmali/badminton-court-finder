import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import { StyleSheet, Text, View } from 'react-native';
import type { RootStackParamList } from '../navigation/RootNavigator';

type Props = NativeStackScreenProps<RootStackParamList, 'VenueList'>;

export function VenueListScreen(_props: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.placeholder}>Venue list — coming in #9</Text>
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
