-- Create the profiles table to store user information
CREATE TABLE profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  email TEXT,
  extraction_count INTEGER DEFAULT 0,
  subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'active')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create Policies for profiles table
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create a trigger function to automatically create a profile when a new user registers
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger that calls the function after a new user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create the recipes table (if you decide to store recipes in the database)
CREATE TABLE recipes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  title TEXT NOT NULL,
  ingredients JSONB NOT NULL, -- Stores ingredients as an array of strings
  instructions JSONB NOT NULL, -- Stores instructions as an array of strings
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on recipes table
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

-- Create Policies for recipes table
CREATE POLICY "Users can view own recipes" ON recipes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own recipes" ON recipes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipes" ON recipes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipes" ON recipes
  FOR DELETE USING (auth.uid() = user_id);

-- Create an index on user_id for efficient lookups
CREATE INDEX idx_recipes_user_id ON recipes(user_id);

-- Create an index on created_at for sorting
CREATE INDEX idx_recipes_created_at ON recipes(created_at);

-- Function to increment extraction count
CREATE OR REPLACE FUNCTION increment_extraction_count(user_id_param UUID)
RETURNS INTEGER AS $$
DECLARE
  new_count INTEGER;
BEGIN
  UPDATE profiles
  SET extraction_count = extraction_count + 1,
      updated_at = NOW()
  WHERE id = user_id_param
  RETURNING extraction_count INTO new_count;
  
  RETURN new_count;
END;
$$ LANGUAGE plpgsql;