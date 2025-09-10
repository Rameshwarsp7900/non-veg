import { useState, useEffect } from 'react'
import { User } from '@supabase/supabase-js'
import { createSupabaseClient } from '@/lib/supabase'
import { Button } from '@/components/ui/Button'
import CalendarView from '@/components/CalendarView'
import TodayStatus from '@/components/TodayStatus'
import EventManager from '@/components/EventManager'
import WeeklyRules from '@/components/WeeklyRules'
import ChatAssistant from '@/components/ChatAssistant'
import { Calendar, CalendarDays, Settings, MessageCircle, LogOut, User as UserIcon } from 'lucide-react'
import { RestrictionType } from '@/types'
import { formatDate } from '@/utils/dateUtils'
import { getDefaultEvents, getDefaultWeeklyRules } from '@/utils/defaultEvents'
import { GenericIcon, getCalendarIcon } from '@/utils/icons'

interface DashboardProps {
  user: User
}

type TabType = 'calendar' | 'events' | 'rules' | 'chat' | 'settings'

export default function Dashboard({ user }: DashboardProps) {
  const [activeTab, setActiveTab] = useState<TabType>('calendar')
  const [userProfile, setUserProfile] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const supabase = createSupabaseClient()

  useEffect(() => {
    initializeUser()
  }, [user])

  const initializeUser = async () => {
    try {
      // Check if user profile exists
      const { data: profile, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single()

      if (error && error.code === 'PGRST116') {
        // Profile doesn't exist, create it
        const { data: newProfile, error: createError } = await supabase
          .from('profiles')
          .insert({
            id: user.id,
            email: user.email!,
            full_name: user.user_metadata?.full_name || null,
            is_family_admin: false,
            enable_notifications: true,
          })
          .select()
          .single()

        if (createError) {
          console.error('Error creating profile:', createError)
        } else {
          setUserProfile(newProfile)
          await setupDefaultData()
        }
      } else if (error) {
        console.error('Error fetching profile:', error)
      } else {
        setUserProfile(profile)
      }
    } catch (error) {
      console.error('Error initializing user:', error)
    } finally {
      setLoading(false)
    }
  }

  const setupDefaultData = async () => {
    try {
      // Add default events for current and next year
      const currentYear = new Date().getFullYear()
      const defaultEvents = [
        ...getDefaultEvents(currentYear, user.id),
        ...getDefaultEvents(currentYear + 1, user.id),
      ]

      await supabase.from('diet_events').insert(defaultEvents)

      // Add default weekly rules
      const defaultRules = getDefaultWeeklyRules(user.id)
      await supabase.from('weekly_rules').insert(defaultRules)
    } catch (error) {
      console.error('Error setting up default data:', error)
    }
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut()
  }

  const getTodayStatus = () => {
    const today = new Date()
    const dayOfWeek = today.getDay() // 0 = Sunday, 1 = Monday, etc.
    
    // Convert to our format (1 = Monday, 7 = Sunday)
    const weekday = dayOfWeek === 0 ? 7 : dayOfWeek
    
    // Check if today is Tuesday (2) or Saturday (6) - traditional Hanuman days
    if (weekday === 2 || weekday === 6) {
      return {
        restriction: RestrictionType.VEG_ONLY,
        reason: `${weekday === 2 ? 'Tuesday' : 'Saturday'} - Hanuman's day (traditional restriction)`,
        statusText: 'Veg Only'
      }
    }
    
    return {
      restriction: RestrictionType.NON_VEG_ALLOWED,
      reason: 'No restrictions apply today',
      statusText: 'Non-Veg OK'
    }
  }

  const tabs = [
    { id: 'calendar', label: 'Calendar', icon: Calendar },
    { id: 'events', label: 'Events', icon: CalendarDays },
    { id: 'rules', label: 'Weekly Rules', icon: Settings },
    { id: 'chat', label: 'Assistant', icon: MessageCircle },
  ]

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <div className="h-8 w-8 bg-primary-600 rounded-lg flex items-center justify-center">
                <GenericIcon src={getCalendarIcon()} size={20} alt="Calendar" className="filter invert" />
              </div>
              <h1 className="ml-3 text-xl font-semibold text-gray-900">
                Veg/Non-Veg Calendar
              </h1>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="flex items-center text-sm text-gray-600">
                <UserIcon className="h-4 w-4 mr-1" />
                {userProfile?.full_name || user.email}
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={handleSignOut}
              >
                <LogOut className="h-4 w-4 mr-2" />
                Sign Out
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation Tabs */}
      <nav className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            {tabs.map((tab) => {
              const Icon = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as TabType)}
                  className={`py-4 px-1 border-b-2 font-medium text-sm ${
                    activeTab === tab.id
                      ? 'border-primary-500 text-primary-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-center">
                    <Icon className="h-5 w-5 mr-2" />
                    {tab.label}
                  </div>
                </button>
              )
            })}
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'calendar' && (
          <div className="space-y-6">
            <TodayStatus status={getTodayStatus()} />
            <CalendarView userId={user.id} />
          </div>
        )}
        
        {activeTab === 'events' && (
          <EventManager userId={user.id} />
        )}
        
        {activeTab === 'rules' && (
          <WeeklyRules userId={user.id} />
        )}
        
        {activeTab === 'chat' && (
          <ChatAssistant userId={user.id} />
        )}
      </main>
    </div>
  )
}