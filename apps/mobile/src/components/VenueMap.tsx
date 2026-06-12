import type { VenueListItem } from '@smash/api-client';
import { Camera, GeoJSONSource, Layer, Map } from '@maplibre/maplibre-react-native';
import { StyleSheet, Text, View } from 'react-native';
import type { UserCoords } from '../utils/filters';

// [lng, lat] — MapLibre order
const SYDNEY: [number, number] = [151.2093, -33.8688];
const DEFAULT_ZOOM = 10;

const MAPTILER_KEY = process.env['EXPO_PUBLIC_MAPTILER_API_KEY'] ?? '';
const STYLE_URL = MAPTILER_KEY
  ? `https://api.maptiler.com/maps/streets-v2/style.json?key=${MAPTILER_KEY}`
  : '';

interface Props {
  venues: VenueListItem[];
  userCoords: UserCoords | null;
  onVenuePress: (venueId: string, venueName: string) => void;
}

export function VenueMap({ venues, userCoords, onVenuePress }: Props) {
  if (!STYLE_URL) {
    return (
      <View style={styles.error}>
        <Text style={styles.errorText}>EXPO_PUBLIC_MAPTILER_API_KEY is not set</Text>
      </View>
    );
  }

  const center: [number, number] = userCoords
    ? [userCoords.longitude, userCoords.latitude]
    : SYDNEY;

  const geojson: GeoJSON.FeatureCollection = {
    type: 'FeatureCollection',
    features: venues.map((v) => ({
      type: 'Feature',
      id: v.id,
      geometry: { type: 'Point', coordinates: [v.lng, v.lat] },
      properties: {
        id: v.id,
        name: v.name,
        dedicated: v.dedicatedBadminton ? 1 : 0,
      },
    })),
  };

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  function handlePress(e: any) {
    const features: GeoJSON.Feature[] = e?.nativeEvent?.features ?? e?.features ?? [];
    const props = features[0]?.properties;
    const id = props?.['id'] as string | undefined;
    const name = props?.['name'] as string | undefined;
    if (id && name) onVenuePress(id, name);
  }

  return (
    <Map style={styles.map} mapStyle={STYLE_URL}>
      <Camera
        initialViewState={{ center, zoom: DEFAULT_ZOOM }}
        center={center}
        zoom={DEFAULT_ZOOM}
        duration={600}
      />
      <GeoJSONSource id="venues" data={geojson} onPress={handlePress}>
        {/* White ring */}
        <Layer
          id="venue-rings"
          type="circle"
          paint={{
            'circle-radius': 13,
            'circle-color': '#ffffff',
            'circle-opacity': 0.9,
          }}
        />
        {/* Filled dot — green = dedicated, blue = multi-sport */}
        <Layer
          id="venue-dots"
          type="circle"
          paint={{
            'circle-radius': 9,
            'circle-color': [
              'case',
              ['==', ['get', 'dedicated'], 1],
              '#00C853',
              '#1565C0',
            ],
          }}
        />
        {/* First letter label */}
        <Layer
          id="venue-labels"
          type="symbol"
          layout={{
            'text-field': ['slice', ['get', 'name'], 0, 1],
            'text-size': 11,
            'text-font': ['Open Sans Bold', 'Arial Unicode MS Regular'],
            'text-allow-overlap': true,
          }}
          paint={{
            'text-color': '#ffffff',
          }}
        />
      </GeoJSONSource>
    </Map>
  );
}

const styles = StyleSheet.create({
  map: { flex: 1 },
  error: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  errorText: { fontSize: 14, color: '#888', textAlign: 'center' },
});
