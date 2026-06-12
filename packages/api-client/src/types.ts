export type VenuePlatform =
  | 'sportlogic'
  | 'skedda'
  | 'pitchbooking'
  | 'yepbooking'
  | 'council'
  | 'other';

export interface VenueListItem {
  id: string;
  name: string;
  suburb: string;
  lat: number;
  lng: number;
  courtCount: number;
  dedicatedBadminton: boolean;
  distanceKm: number | null;
  priceFrom: number | null;
  hasLiveAvailability: boolean;
}

export interface RateCard {
  id: string;
  label: string;
  priceCents: number;
  daysApply: string[];
  timeRangeStart: string | null;
  timeRangeEnd: string | null;
  notes: string | null;
}

export interface OpeningHours {
  dayOfWeek: number;
  openTime: string | null;
  closeTime: string | null;
  isClosed: boolean;
}

export interface VenueDetail extends VenueListItem {
  slug: string;
  address: string;
  phone: string | null;
  email: string | null;
  bookingUrl: string;
  platform: VenuePlatform;
  rateCards: RateCard[];
  openingHours: OpeningHours[];
}

export interface VenueListResponse {
  venues: VenueListItem[];
}

export interface VenueDetailResponse {
  venue: VenueDetail;
}

export interface AvailabilitySlot {
  start: string;
  end: string;
  courtsAvailable: number;
  courtsTotal: number;
}

export interface AvailabilityResponse {
  venueId: string;
  date: string;
  lastUpdated: string | null;
  liveAvailability: boolean;
  slots: AvailabilitySlot[];
}
