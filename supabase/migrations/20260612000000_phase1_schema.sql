-- Phase 1 schema: venues, rate_cards, opening_hours
-- No availability tables — those are Phase 2

-- ─── Enums ───────────────────────────────────────────────────────────────────

create type venue_platform as enum (
  'sportlogic',
  'skedda',
  'pitchbooking',
  'yepbooking',
  'council',
  'other'
);

-- ─── venues ──────────────────────────────────────────────────────────────────

create table venues (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  slug                text not null unique,
  suburb              text not null,
  address             text not null,
  lat                 numeric(9, 6) not null,
  lng                 numeric(9, 6) not null,
  court_count         integer not null check (court_count > 0),
  dedicated_badminton boolean not null default false,
  platform            venue_platform not null,
  booking_url         text not null,
  phone               text,
  email               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index venues_slug_idx on venues (slug);
create index venues_dedicated_idx on venues (dedicated_badminton);
create index venues_platform_idx on venues (platform);

-- updated_at trigger
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger venues_updated_at
  before update on venues
  for each row execute function set_updated_at();

-- ─── rate_cards ──────────────────────────────────────────────────────────────

create table rate_cards (
  id               uuid primary key default gen_random_uuid(),
  venue_id         uuid not null references venues (id) on delete cascade,
  label            text not null,
  price_cents      integer not null check (price_cents >= 0),
  days_apply       text[] not null default '{}',
  time_range_start time,
  time_range_end   time,
  notes            text
);

create index rate_cards_venue_idx on rate_cards (venue_id);

-- ─── opening_hours ───────────────────────────────────────────────────────────

create table opening_hours (
  id           uuid primary key default gen_random_uuid(),
  venue_id     uuid not null references venues (id) on delete cascade,
  day_of_week  integer not null check (day_of_week between 0 and 6),
  open_time    time,
  close_time   time,
  is_closed    boolean not null default false,
  unique (venue_id, day_of_week)
);

create index opening_hours_venue_idx on opening_hours (venue_id);

-- ─── Row-level security ───────────────────────────────────────────────────────

alter table venues enable row level security;
alter table rate_cards enable row level security;
alter table opening_hours enable row level security;

-- anon key: read-only access to all three tables
create policy "anon read venues"
  on venues for select
  to anon
  using (true);

create policy "anon read rate_cards"
  on rate_cards for select
  to anon
  using (true);

create policy "anon read opening_hours"
  on opening_hours for select
  to anon
  using (true);

-- service_role key: full access (bypasses RLS by default — no policy needed)
