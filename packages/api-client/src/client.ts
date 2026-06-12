import type { AvailabilityResponse, VenueDetailResponse, VenueListResponse } from './types';

export interface VenueListParams {
  lat?: number;
  lng?: number;
  radiusKm?: number;
  dedicatedOnly?: boolean;
  maxPrice?: number;
  sort?: 'distance' | 'price';
}

declare const process: { env: Record<string, string | undefined> };

function getBaseUrl(): string {
  const url = process.env['EXPO_PUBLIC_API_URL'];
  if (!url) throw new Error('EXPO_PUBLIC_API_URL is not set');
  return url;
}

async function get<T>(path: string): Promise<T> {
  const res = await fetch(`${getBaseUrl()}${path}`);
  if (!res.ok) throw new Error(`API error ${res.status}: ${path}`);
  return res.json() as Promise<T>;
}

export function getVenues(params: VenueListParams = {}): Promise<VenueListResponse> {
  const query = new URLSearchParams();
  if (params.lat != null) query.set('lat', String(params.lat));
  if (params.lng != null) query.set('lng', String(params.lng));
  if (params.radiusKm != null) query.set('radius_km', String(params.radiusKm));
  if (params.dedicatedOnly) query.set('dedicated_only', 'true');
  if (params.maxPrice != null) query.set('max_price', String(params.maxPrice));
  if (params.sort) query.set('sort', params.sort);
  const qs = query.toString();
  return get<VenueListResponse>(`/venues${qs ? `?${qs}` : ''}`);
}

export function getVenue(id: string): Promise<VenueDetailResponse> {
  return get<VenueDetailResponse>(`/venues/${id}`);
}

export function getVenueAvailability(id: string, date?: string): Promise<AvailabilityResponse> {
  const qs = date ? `?date=${date}` : '';
  return get<AvailabilityResponse>(`/venues/${id}/availability${qs}`);
}
