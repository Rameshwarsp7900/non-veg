-- Quick Setup for Veg/Non-Veg Calendar
-- Copy and paste this into your Supabase SQL Editor

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  birth_date DATE,
  family_group_id UUID,
  is_family_admin BOOLEAN DEFAULT FALSE,
  enable_notifications BOOLEAN DEFAULT TRUE,
  morning_reminder_time TIME,
  evening_reminder_time TIME,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create diet_events table
CREATE TABLE IF NOT EXISTS diet_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  date DATE NOT NULL,
  category TEXT NOT NULL,
  restriction TEXT NOT NULL,
  description TEXT,
  reason TEXT,
  is_recurring BOOLEAN DEFAULT FALSE,
  created_by TEXT,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create weekly_rules table
CREATE TABLE IF NOT EXISTS weekly_rules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  weekday INTEGER NOT NULL CHECK (weekday >= 1 AND weekday <= 7),
  restriction TEXT NOT NULL,
  reason TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, weekday)
);

-- Create manual_overrides table
CREATE TABLE IF NOT EXISTS manual_overrides (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  restriction TEXT NOT NULL,
  reason TEXT NOT NULL,
  notes TEXT,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  text TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE diet_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE manual_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create RLS policies for diet_events
DROP POLICY IF EXISTS "Users can view own events" ON diet_events;
CREATE POLICY "Users can view own events" ON diet_events
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own events" ON diet_events;
CREATE POLICY "Users can create own events" ON diet_events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own events" ON diet_events;
CREATE POLICY "Users can update own events" ON diet_events
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own events" ON diet_events;
CREATE POLICY "Users can delete own events" ON diet_events
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for weekly_rules
DROP POLICY IF EXISTS "Users can view own weekly rules" ON weekly_rules;
CREATE POLICY "Users can view own weekly rules" ON weekly_rules
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own weekly rules" ON weekly_rules;
CREATE POLICY "Users can create own weekly rules" ON weekly_rules
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own weekly rules" ON weekly_rules;
CREATE POLICY "Users can update own weekly rules" ON weekly_rules
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own weekly rules" ON weekly_rules;
CREATE POLICY "Users can delete own weekly rules" ON weekly_rules
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for manual_overrides
DROP POLICY IF EXISTS "Users can view own overrides" ON manual_overrides;
CREATE POLICY "Users can view own overrides" ON manual_overrides
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own overrides" ON manual_overrides;
CREATE POLICY "Users can create own overrides" ON manual_overrides
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own overrides" ON manual_overrides;
CREATE POLICY "Users can update own overrides" ON manual_overrides
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own overrides" ON manual_overrides;
CREATE POLICY "Users can delete own overrides" ON manual_overrides
  FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for chat_messages
DROP POLICY IF EXISTS "Users can view own chat messages" ON chat_messages;
CREATE POLICY "Users can view own chat messages" ON chat_messages
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own chat messages" ON chat_messages;
CREATE POLICY "Users can create own chat messages" ON chat_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_diet_events_updated_at ON diet_events;
CREATE TRIGGER update_diet_events_updated_at
  BEFORE UPDATE ON diet_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_weekly_rules_updated_at ON weekly_rules;
CREATE TRIGGER update_weekly_rules_updated_at
  BEFORE UPDATE ON weekly_rules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_manual_overrides_updated_at ON manual_overrides;
CREATE TRIGGER update_manual_overrides_updated_at
  BEFORE UPDATE ON manual_overrides
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();