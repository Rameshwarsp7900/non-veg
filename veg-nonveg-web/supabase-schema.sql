-- Veg/Non-Veg Decision Calendar Database Schema
-- Run these SQL commands in your Supabase SQL editor

-- Enable Row Level Security
ALTER TABLE IF EXISTS auth.users ENABLE ROW LEVEL SECURITY;

-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  birth_date DATE,
  family_group_id UUID REFERENCES family_groups(id),
  is_family_admin BOOLEAN DEFAULT FALSE,
  enable_notifications BOOLEAN DEFAULT TRUE,
  morning_reminder_time TIME,
  evening_reminder_time TIME,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create family_groups table
CREATE TABLE family_groups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  admin_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create family_members table
CREATE TABLE family_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  family_group_id UUID REFERENCES family_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(family_group_id, user_id)
);

-- Create diet_events table
CREATE TABLE diet_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  date DATE NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('festival', 'eclipse', 'holiday', 'personal', 'weekly', 'family')),
  restriction TEXT NOT NULL CHECK (restriction IN ('non_veg_allowed', 'veg_only', 'conditional')),
  description TEXT,
  reason TEXT,
  is_recurring BOOLEAN DEFAULT FALSE,
  created_by TEXT, -- For family events, tracks who created it
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create weekly_rules table
CREATE TABLE weekly_rules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  weekday INTEGER NOT NULL CHECK (weekday >= 1 AND weekday <= 7), -- 1 = Monday, 7 = Sunday
  restriction TEXT NOT NULL CHECK (restriction IN ('non_veg_allowed', 'veg_only', 'conditional')),
  reason TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, weekday)
);

-- Create manual_overrides table
CREATE TABLE manual_overrides (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  restriction TEXT NOT NULL CHECK (restriction IN ('non_veg_allowed', 'veg_only', 'conditional')),
  reason TEXT NOT NULL,
  notes TEXT,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Create chat_messages table
CREATE TABLE chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  text TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_family_group ON profiles(family_group_id);
CREATE INDEX idx_diet_events_user_date ON diet_events(user_id, date);
CREATE INDEX idx_diet_events_date ON diet_events(date);
CREATE INDEX idx_weekly_rules_user ON weekly_rules(user_id);
CREATE INDEX idx_manual_overrides_user_date ON manual_overrides(user_id, date);
CREATE INDEX idx_chat_messages_user ON chat_messages(user_id, created_at);

-- Enable Row Level Security and create policies

-- Profiles policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Diet events policies
ALTER TABLE diet_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own events" ON diet_events
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own events" ON diet_events
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own events" ON diet_events
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own events" ON diet_events
  FOR DELETE USING (auth.uid() = user_id);

-- Weekly rules policies
ALTER TABLE weekly_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own weekly rules" ON weekly_rules
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own weekly rules" ON weekly_rules
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own weekly rules" ON weekly_rules
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own weekly rules" ON weekly_rules
  FOR DELETE USING (auth.uid() = user_id);

-- Manual overrides policies
ALTER TABLE manual_overrides ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own overrides" ON manual_overrides
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own overrides" ON manual_overrides
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own overrides" ON manual_overrides
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own overrides" ON manual_overrides
  FOR DELETE USING (auth.uid() = user_id);

-- Chat messages policies
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own chat messages" ON chat_messages
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own chat messages" ON chat_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Family groups policies
ALTER TABLE family_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own family groups" ON family_groups
  FOR SELECT USING (
    auth.uid() = admin_user_id OR 
    auth.uid() IN (SELECT user_id FROM family_members WHERE family_group_id = id)
  );
CREATE POLICY "Admins can manage family groups" ON family_groups
  FOR ALL USING (auth.uid() = admin_user_id);

-- Family members policies
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view family members" ON family_members
  FOR SELECT USING (
    auth.uid() = user_id OR
    auth.uid() IN (
      SELECT admin_user_id FROM family_groups WHERE id = family_group_id
    )
  );

-- Create function to handle user registration
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
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_family_groups_updated_at
  BEFORE UPDATE ON family_groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_diet_events_updated_at
  BEFORE UPDATE ON diet_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_weekly_rules_updated_at
  BEFORE UPDATE ON weekly_rules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_manual_overrides_updated_at
  BEFORE UPDATE ON manual_overrides
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();