-- Supabase schema for AquaRuta
-- Run this in the `public` schema of your Supabase Postgres database

-- 1. Enums and custom types
create type public.user_role as enum ('passenger', 'operator', 'admin');

create type public.trip_status as enum ('scheduled', 'boarding', 'in_transit', 'finished', 'cancelled');

create type public.dock_location as enum ('cartagena', 'tierra_bomba');


-- 2. Tables

-- Profiles: extends auth.users with app-specific data
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  role public.user_role not null default 'passenger',
  created_at timestamptz not null default now()
);

-- Boats (Lanchas)
create table public.boats (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  max_capacity integer not null check (max_capacity > 0),
  is_active boolean not null default true
);

-- Trips (Viajes)
create table public.trips (
  id uuid primary key default gen_random_uuid(),
  boat_id uuid not null references public.boats (id) on delete restrict,
  origin public.dock_location not null,
  destination public.dock_location not null,
  departure_time timestamptz not null,
  status public.trip_status not null default 'scheduled',
  available_seats integer not null check (available_seats >= 0)
  -- Nota: available_seats se debe mantener vía triggers o lógica de aplicación
);

-- Bookings (Reservas)
create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  passenger_count integer not null check (passenger_count > 0)
);


-- 3. Row Level Security (RLS)

alter table public.profiles enable row level security;
alter table public.boats enable row level security;
alter table public.trips enable row level security;
alter table public.bookings enable row level security;

-- Políticas genéricas sugeridas (comentadas):

-- -- Operators and admins can manage trips
-- create policy "operators_manage_trips" on public.trips
--   for all
--   using (
--     exists (
--       select 1 from public.profiles p
--       where p.id = auth.uid()
--         and p.role in ('operator', 'admin')
--     )
--   )
--   with check (
--     exists (
--       select 1 from public.profiles p
--       where p.id = auth.uid()
--         and p.role in ('operator', 'admin')
--     )
--   );

-- -- Passengers can read all trips
-- create policy "passengers_read_trips" on public.trips
--   for select
--   using (true);

-- -- Passengers can create their own bookings
-- create policy "passengers_create_own_bookings" on public.bookings
--   for insert
--   with check (user_id = auth.uid());

-- -- Users can read their own bookings
-- create policy "users_read_own_bookings" on public.bookings
--   for select
--   using (user_id = auth.uid());


-- 4. Realtime: add trips table to supabase_realtime publication
alter publication supabase_realtime add table public.trips; 
