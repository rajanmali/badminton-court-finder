import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { VenueDetailScreen } from '../screens/VenueDetailScreen';
import { VenueListScreen } from '../screens/VenueListScreen';

export type RootStackParamList = {
  VenueList: undefined;
  VenueDetail: { venueId: string; venueName: string };
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export function RootNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="VenueList">
        <Stack.Screen
          name="VenueList"
          component={VenueListScreen}
          options={{ title: 'Smash — Find a Court' }}
        />
        <Stack.Screen
          name="VenueDetail"
          component={VenueDetailScreen}
          options={({ route }) => ({ title: route.params.venueName })}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
