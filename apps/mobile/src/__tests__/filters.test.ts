import { haversineKm, applyFilters, withDistances, DEFAULT_FILTERS } from '../utils/filters';
import type { VenueListItem } from '@smash/api-client';

// Approximate: Sydney CBD (-33.8688, 151.2093), Parramatta (-33.8150, 151.0011)
// Real distance ≈ 23 km
const SYDNEY_CBD = { latitude: -33.8688, longitude: 151.2093 };
const PARRAMATTA = { latitude: -33.8150, longitude: 151.0011 };

describe('haversineKm', () => {
  it('returns 0 for same point', () => {
    expect(haversineKm(-33.8688, 151.2093, -33.8688, 151.2093)).toBeCloseTo(0);
  });

  it('calculates Sydney CBD to Parramatta (~23 km)', () => {
    const d = haversineKm(SYDNEY_CBD.latitude, SYDNEY_CBD.longitude, PARRAMATTA.latitude, PARRAMATTA.longitude);
    expect(d).toBeGreaterThan(20);
    expect(d).toBeLessThan(26);
  });

  it('is symmetric', () => {
    const ab = haversineKm(-33.8688, 151.2093, -33.8150, 151.0011);
    const ba = haversineKm(-33.8150, 151.0011, -33.8688, 151.2093);
    expect(ab).toBeCloseTo(ba, 5);
  });
});

function makeVenue(overrides: Partial<VenueListItem>): VenueListItem {
  return {
    id: 'v1',
    name: 'Test Venue',
    suburb: 'Test',
    lat: -33.8688,
    lng: 151.2093,
    courtCount: 4,
    dedicatedBadminton: false,
    distanceKm: null,
    priceFrom: 3000,
    hasLiveAvailability: false,
    ...overrides,
  };
}

const NEAR = makeVenue({ id: 'near', name: 'Near', lat: -33.8700, lng: 151.2100, priceFrom: 2900 }); // ~0.1 km from CBD
const FAR = makeVenue({ id: 'far', name: 'Far', lat: -33.8150, lng: 151.0011, priceFrom: 3000 });    // ~23 km
const DEDICATED = makeVenue({ id: 'ded', name: 'Dedicated', lat: -33.86, lng: 151.20, dedicatedBadminton: true, priceFrom: 3500 });
const NO_RATES = makeVenue({ id: 'norates', name: 'No Rates', lat: -33.86, lng: 151.21, priceFrom: null });

const ALL = [NEAR, FAR, DEDICATED, NO_RATES];

describe('withDistances', () => {
  it('sets distanceKm when userCoords provided', () => {
    const result = withDistances([NEAR], SYDNEY_CBD);
    expect(result[0]!.distanceKm).not.toBeNull();
    expect(result[0]!.distanceKm!).toBeLessThan(1);
  });

  it('sets distanceKm to null when no userCoords', () => {
    const result = withDistances([NEAR], null);
    expect(result[0]!.distanceKm).toBeNull();
  });
});

describe('applyFilters — no filters', () => {
  it('returns all venues sorted alphabetically when no location', () => {
    const result = applyFilters(ALL, DEFAULT_FILTERS, null);
    expect(result.map((v) => v.id)).toEqual(['ded', 'far', 'near', 'norates']);
  });

  it('sorts by distance when location available', () => {
    const result = applyFilters([NEAR, FAR], DEFAULT_FILTERS, SYDNEY_CBD);
    expect(result[0]!.id).toBe('near');
    expect(result[1]!.id).toBe('far');
  });
});

describe('applyFilters — dedicated toggle', () => {
  it('filters to dedicated only', () => {
    const result = applyFilters(ALL, { ...DEFAULT_FILTERS, dedicatedOnly: true }, null);
    expect(result.every((v) => v.dedicatedBadminton)).toBe(true);
    expect(result.length).toBe(1);
    expect(result[0]!.id).toBe('ded');
  });
});

describe('applyFilters — max price', () => {
  it('excludes venues above price limit', () => {
    const result = applyFilters(ALL, { ...DEFAULT_FILTERS, maxPriceCents: 3000 }, null);
    const ids = result.map((v) => v.id);
    expect(ids).toContain('near');   // 2900 ≤ 3000 ✓
    expect(ids).toContain('far');    // 3000 ≤ 3000 ✓
    expect(ids).not.toContain('ded'); // 3500 > 3000 ✗
  });

  it('keeps venues with no rates (priceFrom null)', () => {
    const result = applyFilters(ALL, { ...DEFAULT_FILTERS, maxPriceCents: 2000 }, null);
    expect(result.map((v) => v.id)).toContain('norates');
  });
});

describe('applyFilters — distance radius', () => {
  it('excludes venues outside radius', () => {
    const result = applyFilters([NEAR, FAR], { ...DEFAULT_FILTERS, radiusKm: 5 }, SYDNEY_CBD);
    expect(result.map((v) => v.id)).toContain('near');
    expect(result.map((v) => v.id)).not.toContain('far');
  });

  it('ignores radius filter when no userCoords', () => {
    const result = applyFilters([NEAR, FAR], { ...DEFAULT_FILTERS, radiusKm: 5 }, null);
    expect(result.length).toBe(2);
  });
});

describe('applyFilters — combined', () => {
  it('applies all three filters with AND logic', () => {
    const result = applyFilters(ALL, { radiusKm: 5, maxPriceCents: 3000, dedicatedOnly: false }, SYDNEY_CBD);
    // Near (2900, non-dedicated, ~0.1km) ✓  Far (~23km) ✗  Dedicated (3500) ✗  No rates (null price, ~0.5km) ✓
    const ids = result.map((v) => v.id);
    expect(ids).toContain('near');
    expect(ids).toContain('norates');
    expect(ids).not.toContain('far');
    expect(ids).not.toContain('ded');
  });
});
