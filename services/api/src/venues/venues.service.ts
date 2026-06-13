import { Injectable, OnModuleInit } from '@nestjs/common';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

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
  platform: string;
  rateCards: RateCard[];
  openingHours: OpeningHours[];
}

@Injectable()
export class VenuesService implements OnModuleInit {
  private supabase!: SupabaseClient;

  onModuleInit() {
    const url = process.env['SUPABASE_URL'];
    const key = process.env['SUPABASE_SERVICE_ROLE_KEY'];
    if (!url || !key) throw new Error('SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set');
    this.supabase = createClient(url, key);
  }

  async findOne(id: string): Promise<VenueDetail | null> {
    const { data, error } = await this.supabase
      .from('venues')
      .select(`
        id, name, slug, suburb, address, lat, lng, court_count, dedicated_badminton,
        platform, booking_url, phone, email,
        rate_cards(id, label, price_cents, days_apply, time_range_start, time_range_end, notes),
        opening_hours(day_of_week, open_time, close_time, is_closed)
      `)
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null; // no rows
      throw new Error(`Supabase error: ${error.message}`);
    }
    if (!data) return null;

    const rates = (data.rate_cards as any[] | null) ?? [];
    const hours = (data.opening_hours as any[] | null) ?? [];
    const priceFrom = rates.length > 0 ? Math.min(...rates.map((r) => r.price_cents as number)) : null;

    return {
      id: data.id as string,
      name: data.name as string,
      slug: data.slug as string,
      suburb: data.suburb as string,
      address: data.address as string,
      lat: Number(data.lat),
      lng: Number(data.lng),
      courtCount: data.court_count as number,
      dedicatedBadminton: data.dedicated_badminton as boolean,
      platform: data.platform as string,
      bookingUrl: data.booking_url as string,
      phone: (data.phone as string | null) ?? null,
      email: (data.email as string | null) ?? null,
      distanceKm: null,
      priceFrom,
      hasLiveAvailability: false,
      rateCards: rates.map((r) => ({
        id: r.id as string,
        label: r.label as string,
        priceCents: r.price_cents as number,
        daysApply: (r.days_apply as string[]) ?? [],
        timeRangeStart: (r.time_range_start as string | null) ?? null,
        timeRangeEnd: (r.time_range_end as string | null) ?? null,
        notes: (r.notes as string | null) ?? null,
      })),
      openingHours: hours
        .sort((a, b) => (a.day_of_week as number) - (b.day_of_week as number))
        .map((h) => ({
          dayOfWeek: h.day_of_week as number,
          openTime: (h.open_time as string | null) ?? null,
          closeTime: (h.close_time as string | null) ?? null,
          isClosed: h.is_closed as boolean,
        })),
    };
  }

  async findAll(): Promise<VenueListItem[]> {
    const { data, error } = await this.supabase
      .from('venues')
      .select('id, name, suburb, lat, lng, court_count, dedicated_badminton, rate_cards(price_cents)')
      .order('name');

    if (error) throw new Error(`Supabase error: ${error.message}`);

    return (data ?? []).map((row) => {
      const rates = (row.rate_cards as { price_cents: number }[] | null) ?? [];
      const priceFrom = rates.length > 0 ? Math.min(...rates.map((r) => r.price_cents)) : null;
      return {
        id: row.id as string,
        name: row.name as string,
        suburb: row.suburb as string,
        lat: Number(row.lat),
        lng: Number(row.lng),
        courtCount: row.court_count as number,
        dedicatedBadminton: row.dedicated_badminton as boolean,
        distanceKm: null,
        priceFrom,
        hasLiveAvailability: false,
      };
    });
  }
}
