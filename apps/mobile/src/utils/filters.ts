import type { VenueListItem } from '@smash/api-client';

export interface UserCoords {
  latitude: number;
  longitude: number;
}

export interface FilterState {
  radiusKm: number | null;      // null = Any distance
  maxPriceCents: number | null; // null = Any price
  dedicatedOnly: boolean;
}

export const DEFAULT_FILTERS: FilterState = {
  radiusKm: null,
  maxPriceCents: null,
  dedicatedOnly: false,
};

// Haversine great-circle distance in km
export function haversineKm(
  lat1: number, lng1: number,
  lat2: number, lng2: number,
): number {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

export function withDistances(
  venues: VenueListItem[],
  userCoords: UserCoords | null,
): VenueListItem[] {
  if (!userCoords) return venues.map((v) => ({ ...v, distanceKm: null }));
  return venues.map((v) => ({
    ...v,
    distanceKm: haversineKm(userCoords.latitude, userCoords.longitude, v.lat, v.lng),
  }));
}

export function applyFilters(
  venues: VenueListItem[],
  filters: FilterState,
  userCoords: UserCoords | null,
): VenueListItem[] {
  const enriched = withDistances(venues, userCoords);

  const filtered = enriched.filter((v) => {
    if (filters.dedicatedOnly && !v.dedicatedBadminton) return false;

    if (filters.maxPriceCents !== null) {
      // Exclude venues where lowest rate exceeds the limit.
      // Venues with no rates (priceFrom === null) are kept — user can't filter out unknown prices.
      if (v.priceFrom !== null && v.priceFrom > filters.maxPriceCents) return false;
    }

    if (filters.radiusKm !== null && userCoords) {
      if (v.distanceKm === null || v.distanceKm > filters.radiusKm) return false;
    }

    return true;
  });

  // Sort: by distance if available, else alphabetically
  return filtered.sort((a, b) => {
    if (a.distanceKm !== null && b.distanceKm !== null) return a.distanceKm - b.distanceKm;
    return a.name.localeCompare(b.name);
  });
}
