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

@Injectable()
export class VenuesService implements OnModuleInit {
  private supabase!: SupabaseClient;

  onModuleInit() {
    const url = process.env['SUPABASE_URL'];
    const key = process.env['SUPABASE_SERVICE_ROLE_KEY'];
    if (!url || !key) throw new Error('SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set');
    this.supabase = createClient(url, key);
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
