-- Smart Grievance (Arunachal Pradesh) - Supabase PostgreSQL Schema
-- Run this in your Supabase SQL Editor to create the tables.

create table if not exists public.profiles (
  phone_number text primary key,
  full_name text not null,
  email text,
  district text not null,
  photo_base64 text,
  updated_at timestamptz default now()
);

create table if not exists public.grievances (
  id text primary key,
  reference_number text unique not null,
  user_phone text,
  category text not null,
  title text not null,
  description text not null,
  location_address text not null,
  latitude double precision not null default 27.1025,
  longitude double precision not null default 93.6160,
  status text not null default 'Submitted',
  attachments jsonb default '[]'::jsonb,
  timeline jsonb default '[]'::jsonb,
  feedback jsonb,
  created_at timestamptz default now()
);

create table if not exists public.notifications (
  id text primary key,
  user_phone text,
  type text not null,
  title text not null,
  description text not null,
  grievance_id text references public.grievances(id) on delete cascade,
  is_read boolean default false,
  created_at timestamptz default now()
);

-- Enable Row Level Security (service/secret key bypasses RLS on backend)
alter table public.profiles enable row level security;
alter table public.grievances enable row level security;
alter table public.notifications enable row level security;
