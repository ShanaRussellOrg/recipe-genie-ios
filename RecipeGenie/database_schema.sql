-- Recipe Genie Database Schema for Supabase

-- Enable Row Level Security (RLS) on all tables
alter table "profiles" enable row level security;

-- Create the profiles table to store user information
create table "profiles" (
  "id" uuid references auth.users not null primary key,
  "extraction_count" integer default 0,
  "subscription_status" text default 'free' check (subscription_status in ('free', 'active')),
  "created_at" timestamp with time zone default now(),
  "updated_at" timestamp with time zone default now()
);

-- Create a trigger to update the updated_at column
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language 'plpgsql';

create trigger update_profiles_updated_at 
  before update on profiles 
  for each row 
  execute procedure update_updated_at_column();

-- Create a trigger function to automatically create a profile when a new user registers
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, extraction_count, subscription_status)
  values (new.id, 0, 'free');
  return new;
end;
$$ language plpgsql security definer;

-- Create the trigger that calls the function after a new user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Create RLS policies for profiles table
create policy "Users can view own profile" on profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

-- Create the recipes table (optional - if you want to store recipes in the database)
create table "recipes" (
  "id" uuid default gen_random_uuid() primary key,
  "user_id" uuid references auth.users not null,
  "title" text not null,
  "ingredients" jsonb not null, -- Stores ingredients as an array of strings
  "instructions" jsonb not null, -- Stores instructions as an array of strings
  "created_at" timestamp with time zone default now(),
  "updated_at" timestamp with time zone default now()
);

-- Enable RLS on recipes table
alter table "recipes" enable row level security;

-- Create RLS policies for recipes table
create policy "Users can view own recipes" on recipes
  for select using (auth.uid() = user_id);

create policy "Users can create own recipes" on recipes
  for insert with check (auth.uid() = user_id);

create policy "Users can update own recipes" on recipes
  for update using (auth.uid() = user_id);

create policy "Users can delete own recipes" on recipes
  for delete using (auth.uid() = user_id);

-- Create indexes for better performance
create index if not exists idx_recipes_user_id on recipes(user_id);
create index if not exists idx_recipes_created_at on recipes(created_at);

-- Function to increment extraction count
create or replace function increment_extraction_count(user_id_param uuid)
returns integer as $$
declare
  new_count integer;
begin
  update profiles
  set extraction_count = extraction_count + 1,
      updated_at = now()
  where id = user_id_param
  returning extraction_count into new_count;
  
  return new_count;
end;
$$ language plpgsql;