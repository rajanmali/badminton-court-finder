import { useEffect, useState } from 'react';
import * as Location from 'expo-location';
import type { UserCoords } from '../utils/filters';

interface LocationState {
  coords: UserCoords | null;
  permissionDenied: boolean;
  loading: boolean;
}

export function useLocation(): LocationState {
  const [state, setState] = useState<LocationState>({
    coords: null,
    permissionDenied: false,
    loading: true,
  });

  useEffect(() => {
    let cancelled = false;

    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (cancelled) return;

      if (status !== 'granted') {
        setState({ coords: null, permissionDenied: true, loading: false });
        return;
      }

      try {
        const loc = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.Balanced });
        if (!cancelled) {
          setState({
            coords: { latitude: loc.coords.latitude, longitude: loc.coords.longitude },
            permissionDenied: false,
            loading: false,
          });
        }
      } catch {
        if (!cancelled) setState({ coords: null, permissionDenied: false, loading: false });
      }
    })();

    return () => { cancelled = true; };
  }, []);

  return state;
}
