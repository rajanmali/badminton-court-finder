-- Phase 1 seed data — Sydney badminton venues
-- Idempotent: safe to re-run. Venues upsert on slug.
-- Rate cards and opening hours are deleted and reinserted per venue on each run.
--
-- Lat/lng are approximate suburb-level coordinates — verify and update
-- by right-clicking each address in Google Maps → "Copy coordinates".
-- Data quality notes per venue are inline.

-- ─── Helper: upsert venue, return id ─────────────────────────────────────────

do $seed$
declare
  v_id uuid;
begin

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. The Badminton Club — Wetherill Park
--    Data quality: verified from venue's court hire page
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'The Badminton Club — Wetherill Park',
  'the-badminton-club-wetherill-park',
  'Wetherill Park',
  '5 Wetherill Street, Wetherill Park NSW 2164',
  -33.841900, 150.901900,  -- approximate: verify
  7, true, 'sportlogic',
  'https://wetherillpark.thebadmintonclub.com.au',
  '1300 754 078',
  'wetherillpark@thebadmintonclub.com.au'
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
insert into rate_cards (venue_id, label, price_cents, days_apply, time_range_start, time_range_end, notes) values
  (v_id, 'Off-Peak', 2900, array['mon','tue','wed','thu','fri'], '05:00', '16:00', null),
  (v_id, 'Peak',     3600, array['mon','tue','wed','thu','fri','sat','sun'], '16:00', '22:00', null),
  (v_id, 'Late Night Special', 2900, array['mon','tue','wed','thu','fri','sat','sun'], '22:00', '00:00', null);

delete from opening_hours where venue_id = v_id;
insert into opening_hours (venue_id, day_of_week, open_time, close_time, is_closed) values
  (v_id, 0, '05:00', '00:00', false),
  (v_id, 1, '05:00', '00:00', false),
  (v_id, 2, '05:00', '00:00', false),
  (v_id, 3, '05:00', '00:00', false),
  (v_id, 4, '05:00', '00:00', false),
  (v_id, 5, '05:00', '00:00', false),
  (v_id, 6, '05:00', '00:00', false);

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. The Badminton Club — Prestons
--    Data quality: same operator as Wetherill Park; hours/rates likely same
--    but not yet verified on Prestons' own page — flagged
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'The Badminton Club — Prestons',
  'the-badminton-club-prestons',
  'Prestons',
  'Prestons NSW 2170',  -- full address not yet collected
  -33.935500, 150.864500,  -- approximate: verify
  10, true, 'sportlogic',
  'https://prestons.thebadmintonclub.com.au',
  '1300 754 078',
  'prestons@thebadmintonclub.com.au'
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
-- Rates not yet verified for Prestons specifically — no rate cards seeded
-- to avoid fabricating values. Add once confirmed.

delete from opening_hours where venue_id = v_id;
-- Hours not yet verified — skipping

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. Pro1 Badminton — Bankstown
--    Data quality: verified from venue's court hire page
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'Pro1 Badminton — Bankstown',
  'pro1-badminton-bankstown',
  'Bankstown',
  'Bankstown Aerodrome, Bankstown NSW 2200',
  -33.919200, 151.008500,  -- approximate: verify exact address
  14, true, 'sportlogic',
  'https://booking.pro1badminton.com.au',
  null,
  'info@pro1badminton.com.au'
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
insert into rate_cards (venue_id, label, price_cents, days_apply, time_range_start, time_range_end, notes) values
  (v_id, 'Off-Peak', 2900, array['mon','tue','wed','thu','fri'], '06:00', '16:00', null),
  (v_id, 'Peak',     3400, array['mon','tue','wed','thu','fri','sat','sun'], '16:00', '00:00', 'Includes public holidays. Racquet hire available during staffed hours 4–10pm.');

delete from opening_hours where venue_id = v_id;
-- Hours not yet verified — skipping

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. Sydney Sports Club — Kings Park
--    Data quality: rates from venue site; note that checkout is authoritative
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'Sydney Sports Club — Kings Park',
  'sydney-sports-club-kings-park',
  'Kings Park',
  'Kings Park NSW 2148',  -- full address not yet collected
  -33.742100, 150.914400,  -- approximate: verify
  4, false, 'sportlogic',  -- court_count not verified; 4 is placeholder — update once confirmed
  'https://booking.sydneysportsclub.com.au',
  '0423 227 477',
  'info@sydneysportsclub.com.au'
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
insert into rate_cards (venue_id, label, price_cents, days_apply, time_range_start, time_range_end, notes) values
  (v_id, 'Off-Peak',      2100, array['mon','tue','wed','thu','fri'], '05:00', '17:00', 'Checkout rates are authoritative if different'),
  (v_id, 'Weekend Offer', 3200, array['sat','sun'], '12:00', '21:00', null),
  (v_id, 'Weekend Off-Peak', 2100, array['sat','sun'], '21:00', '00:00', null),
  (v_id, 'Peak',          4200, array['mon','tue','wed','thu','fri'], '17:00', '22:00', null);

delete from opening_hours where venue_id = v_id;
-- Hours not yet verified — skipping

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. Sydney Sports Club — Rouse Hill
--    Data quality: same operator as Kings Park; same rates assumed
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'Sydney Sports Club — Rouse Hill',
  'sydney-sports-club-rouse-hill',
  'Rouse Hill',
  'Rouse Hill NSW 2155',  -- full address not yet collected
  -33.681300, 150.922400,  -- approximate: verify
  4, false, 'sportlogic',  -- court_count not verified; 4 is placeholder
  'https://booking.sydneysportsclub.com.au',
  '0423 227 477',
  'info@sydneysportsclub.com.au'
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
insert into rate_cards (venue_id, label, price_cents, days_apply, time_range_start, time_range_end, notes) values
  (v_id, 'Off-Peak',      2100, array['mon','tue','wed','thu','fri'], '05:00', '17:00', 'Same rate structure as Kings Park — verify'),
  (v_id, 'Weekend Offer', 3200, array['sat','sun'], '12:00', '21:00', null),
  (v_id, 'Weekend Off-Peak', 2100, array['sat','sun'], '21:00', '00:00', null),
  (v_id, 'Peak',          4200, array['mon','tue','wed','thu','fri'], '17:00', '22:00', null);

delete from opening_hours where venue_id = v_id;
-- Hours not yet verified — skipping

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. Sydney Olympic Park Sports Halls
--    Data quality: hours verified; badminton rate is third-party estimate — verify
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'Sydney Olympic Park Sports Halls',
  'sydney-olympic-park-sports-halls',
  'Sydney Olympic Park',
  'Sydney Olympic Park NSW 2127',
  -33.847400, 151.070400,
  12, false, 'pitchbooking',
  'https://www.sydneyolympicpark.com.au/venues/sports-halls',
  '02 9714 7600',
  'sportshalls@sopa.nsw.gov.au'
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
insert into rate_cards (venue_id, label, price_cents, days_apply, time_range_start, time_range_end, notes) values
  (v_id, 'Badminton', 2800, array['mon','tue','wed','thu','fri','sat','sun'], null, null,
   'Third-party estimate ~$26–30/hr — verify on official site before launch');

delete from opening_hours where venue_id = v_id;
insert into opening_hours (venue_id, day_of_week, open_time, close_time, is_closed) values
  (v_id, 0, '08:00', '21:00', false),  -- Sun
  (v_id, 1, '16:00', '22:00', false),  -- Mon
  (v_id, 2, '12:00', '22:00', false),  -- Tue
  (v_id, 3, '12:00', '22:00', false),  -- Wed
  (v_id, 4, '12:00', '22:00', false),  -- Thu
  (v_id, 5, '16:00', '22:00', false),  -- Fri
  (v_id, 6, '08:00', '21:00', false);  -- Sat

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. Five Dock Leisure Centre
--    Data quality: verified from venue's own site
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'Five Dock Leisure Centre',
  'five-dock-leisure-centre',
  'Five Dock',
  'Five Dock NSW 2046',  -- full address not yet collected
  -33.863200, 151.129100,  -- approximate: verify
  8, false, 'council',
  'https://www.fdlc.com.au',
  '(02) 9911 6300',
  'info@fdlc.com.au'
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
insert into rate_cards (venue_id, label, price_cents, days_apply, time_range_start, time_range_end, notes) values
  (v_id, 'Off-Peak', 2850, array['mon','tue','wed','thu','fri'], '06:00', '16:00', '48-hour cancellation policy, payment required at booking'),
  (v_id, 'Peak',     3800, array['mon','tue','wed','thu','fri'], '16:00', '22:00', '48-hour cancellation policy'),
  (v_id, 'Weekend',  3800, array['sat','sun'], null, null, '48-hour cancellation policy');

delete from opening_hours where venue_id = v_id;
-- Hours not yet verified — skipping

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. Concord Oval Recreation Centre
--    Data quality: rates from shared badminton page with Five Dock (same operator)
-- ═══════════════════════════════════════════════════════════════════════════
insert into venues (name, slug, suburb, address, lat, lng, court_count,
  dedicated_badminton, platform, booking_url, phone, email)
values (
  'Concord Oval Recreation Centre',
  'concord-oval-recreation-centre',
  'Concord',
  'Concord NSW 2137',  -- full address not yet collected
  -33.863600, 151.101400,  -- approximate: verify
  8, false, 'council',
  'https://www.concordrec.com.au',
  null,
  null  -- contact via concordrec.com.au/about/contact-us
)
on conflict (slug) do update set
  name = excluded.name, suburb = excluded.suburb,
  address = excluded.address, lat = excluded.lat, lng = excluded.lng,
  court_count = excluded.court_count, dedicated_badminton = excluded.dedicated_badminton,
  platform = excluded.platform, booking_url = excluded.booking_url,
  phone = excluded.phone, email = excluded.email
returning id into v_id;

delete from rate_cards where venue_id = v_id;
insert into rate_cards (venue_id, label, price_cents, days_apply, time_range_start, time_range_end, notes) values
  (v_id, 'Off-Peak', 2850, array['mon','tue','wed','thu','fri'], '06:00', '16:00', 'Same rates as Five Dock — shared operator'),
  (v_id, 'Peak',     3800, array['mon','tue','wed','thu','fri'], '16:00', '22:00', null),
  (v_id, 'Weekend',  3800, array['sat','sun'], null, null, null);

delete from opening_hours where venue_id = v_id;
-- Hours not yet verified — skipping

end $seed$;
