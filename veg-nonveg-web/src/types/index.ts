export enum RestrictionType {
  NON_VEG_ALLOWED = 'non_veg_allowed',
  VEG_ONLY = 'veg_only',
  CONDITIONAL = 'conditional',
}

export enum EventCategory {
  FESTIVAL = 'festival',
  ECLIPSE = 'eclipse',
  HOLIDAY = 'holiday',
  PERSONAL = 'personal',
  WEEKLY = 'weekly',
  FAMILY = 'family',
}

export interface DietEvent {
  id: string;
  name: string;
  date: string; // ISO date string
  category: EventCategory;
  restriction: RestrictionType;
  description?: string;
  reason?: string;
  is_recurring: boolean;
  created_by?: string;
  user_id: string;
  created_at: string;
  updated_at: string;
}

export interface WeeklyRule {
  id: string;
  weekday: number; // 1 = Monday, 7 = Sunday
  restriction: RestrictionType;
  reason: string;
  is_active: boolean;
  user_id: string;
  created_at: string;
  updated_at: string;
}

export interface UserProfile {
  id: string;
  email: string;
  full_name?: string;
  birth_date?: string;
  family_group_id?: string;
  is_family_admin: boolean;
  enable_notifications: boolean;
  morning_reminder_time?: string;
  evening_reminder_time?: string;
  created_at: string;
  updated_at: string;
}

export interface ManualOverride {
  id: string;
  date: string; // ISO date string
  restriction: RestrictionType;
  reason: string;
  notes?: string;
  user_id: string;
  created_at: string;
  updated_at: string;
}

export interface DayStatus {
  date: string;
  restriction: RestrictionType;
  reason: string;
  events: DietEvent[];
  user_notes?: string;
  has_user_override: boolean;
}

export interface FamilyGroup {
  id: string;
  name: string;
  admin_user_id: string;
  created_at: string;
  updated_at: string;
}

export interface FamilyMember {
  id: string;
  family_group_id: string;
  user_id: string;
  role: 'admin' | 'member';
  joined_at: string;
}

export interface ChatMessage {
  id: string;
  text: string;
  is_user: boolean;
  timestamp: string;
  user_id: string;
  created_at: string;
}

// Utility types
export interface CalendarDay {
  date: Date;
  isCurrentMonth: boolean;
  isToday: boolean;
  isSelected: boolean;
  status: DayStatus;
}

export interface QuickAction {
  id: string;
  label: string;
  icon: string;
  action: () => void;
}

// API Response types
export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  count: number;
  page: number;
  limit: number;
  total_pages: number;
}