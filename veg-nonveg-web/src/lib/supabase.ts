import { createClientComponentClient, createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export const createClient = () => {
  return createClientComponentClient()
}

export const createServerClient = () => {
  return createServerComponentClient({ cookies })
}

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          email: string
          full_name: string | null
          birth_date: string | null
          family_group_id: string | null
          is_family_admin: boolean
          enable_notifications: boolean
          morning_reminder_time: string | null
          evening_reminder_time: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          email: string
          full_name?: string | null
          birth_date?: string | null
          family_group_id?: string | null
          is_family_admin?: boolean
          enable_notifications?: boolean
          morning_reminder_time?: string | null
          evening_reminder_time?: string | null
        }
        Update: {
          id?: string
          email?: string
          full_name?: string | null
          birth_date?: string | null
          family_group_id?: string | null
          is_family_admin?: boolean
          enable_notifications?: boolean
          morning_reminder_time?: string | null
          evening_reminder_time?: string | null
          updated_at?: string
        }
      }
      diet_events: {
        Row: {
          id: string
          name: string
          date: string
          category: string
          restriction: string
          description: string | null
          reason: string | null
          is_recurring: boolean
          created_by: string | null
          user_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          date: string
          category: string
          restriction: string
          description?: string | null
          reason?: string | null
          is_recurring?: boolean
          created_by?: string | null
          user_id: string
        }
        Update: {
          id?: string
          name?: string
          date?: string
          category?: string
          restriction?: string
          description?: string | null
          reason?: string | null
          is_recurring?: boolean
          created_by?: string | null
          user_id?: string
          updated_at?: string
        }
      }
      weekly_rules: {
        Row: {
          id: string
          weekday: number
          restriction: string
          reason: string
          is_active: boolean
          user_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          weekday: number
          restriction: string
          reason: string
          is_active?: boolean
          user_id: string
        }
        Update: {
          id?: string
          weekday?: number
          restriction?: string
          reason?: string
          is_active?: boolean
          user_id?: string
          updated_at?: string
        }
      }
      manual_overrides: {
        Row: {
          id: string
          date: string
          restriction: string
          reason: string
          notes: string | null
          user_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          date: string
          restriction: string
          reason: string
          notes?: string | null
          user_id: string
        }
        Update: {
          id?: string
          date?: string
          restriction?: string
          reason?: string
          notes?: string | null
          user_id?: string
          updated_at?: string
        }
      }
      family_groups: {
        Row: {
          id: string
          name: string
          admin_user_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          admin_user_id: string
        }
        Update: {
          id?: string
          name?: string
          admin_user_id?: string
          updated_at?: string
        }
      }
      family_members: {
        Row: {
          id: string
          family_group_id: string
          user_id: string
          role: string
          joined_at: string
        }
        Insert: {
          id?: string
          family_group_id: string
          user_id: string
          role?: string
        }
        Update: {
          id?: string
          family_group_id?: string
          user_id?: string
          role?: string
        }
      }
      chat_messages: {
        Row: {
          id: string
          text: string
          is_user: boolean
          timestamp: string
          user_id: string
          created_at: string
        }
        Insert: {
          id?: string
          text: string
          is_user: boolean
          timestamp: string
          user_id: string
        }
        Update: {
          id?: string
          text?: string
          is_user?: boolean
          timestamp?: string
          user_id?: string
        }
      }
    }
  }
}