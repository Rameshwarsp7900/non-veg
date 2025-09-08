'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase'
import { Button } from '@/components/ui/Button'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { formatDate, getCalendarDays, isSameDayHelper, isTodayHelper } from '@/utils/dateUtils'
import { DietEvent, RestrictionType } from '@/types'

interface CalendarViewProps {
  userId: string
}

export default function CalendarView({ userId }: CalendarViewProps) {
  const [currentMonth, setCurrentMonth] = useState(new Date())
  const [events, setEvents] = useState<DietEvent[]>([])
  const [weeklyRules, setWeeklyRules] = useState<any[]>([])
  const [selectedDate, setSelectedDate] = useState<Date | null>(null)
  const [loading, setLoading] = useState(true)
  
  const supabase = createClient()

  useEffect(() => {
    loadData()
  }, [currentMonth, userId])

  const loadData = async () => {
    try {
      setLoading(true)
      
      // Load events for the current month
      const startOfMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth(), 1)
      const endOfMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 0)
      
      const { data: eventsData } = await supabase
        .from('diet_events')
        .select('*')
        .eq('user_id', userId)
        .gte('date', formatDate(startOfMonth))
        .lte('date', formatDate(endOfMonth))
      
      const { data: rulesData } = await supabase
        .from('weekly_rules')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true)
      
      setEvents(eventsData || [])
      setWeeklyRules(rulesData || [])
    } catch (error) {
      console.error('Error loading calendar data:', error)
    } finally {
      setLoading(false)
    }
  }

  const getDayStatus = (date: Date) => {
    const dateStr = formatDate(date)
    
    // Check for events on this date
    const dayEvents = events.filter(event => event.date === dateStr)
    if (dayEvents.length > 0) {
      const vegOnlyEvents = dayEvents.filter(event => event.restriction === RestrictionType.VEG_ONLY)
      if (vegOnlyEvents.length > 0) {
        return {
          restriction: RestrictionType.VEG_ONLY,
          color: 'bg-vegOnly-100 border-vegOnly-300 text-vegOnly-800',
          icon: '❌'
        }
      }
      
      const conditionalEvents = dayEvents.filter(event => event.restriction === RestrictionType.CONDITIONAL)
      if (conditionalEvents.length > 0) {
        return {
          restriction: RestrictionType.CONDITIONAL,
          color: 'bg-conditional-100 border-conditional-300 text-conditional-800',
          icon: '⚠️'
        }
      }
    }
    
    // Check weekly rules
    const dayOfWeek = date.getDay()
    const weekday = dayOfWeek === 0 ? 7 : dayOfWeek // Convert to our format
    
    const weeklyRule = weeklyRules.find(rule => rule.weekday === weekday)
    if (weeklyRule && weeklyRule.restriction === RestrictionType.VEG_ONLY) {
      return {
        restriction: RestrictionType.VEG_ONLY,
        color: 'bg-vegOnly-100 border-vegOnly-300 text-vegOnly-800',
        icon: '❌'
      }
    }
    
    // Default: non-veg allowed
    return {
      restriction: RestrictionType.NON_VEG_ALLOWED,
      color: 'bg-primary-100 border-primary-300 text-primary-800',
      icon: '✅'
    }
  }

  const calendarDays = getCalendarDays(currentMonth)
  const monthYear = currentMonth.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })

  const navigateMonth = (direction: 'prev' | 'next') => {
    setCurrentMonth(prev => {
      const newMonth = new Date(prev)
      if (direction === 'prev') {
        newMonth.setMonth(prev.getMonth() - 1)
      } else {
        newMonth.setMonth(prev.getMonth() + 1)
      }
      return newMonth
    })
  }

  return (
    <div className="card">
      {/* Calendar Header */}
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-gray-900">{monthYear}</h2>
        <div className="flex space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => navigateMonth('prev')}
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => navigateMonth('next')}
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Legend */}
      <div className="flex justify-center space-x-6 mb-6 p-4 bg-gray-50 rounded-lg">
        <div className="flex items-center">
          <span className="text-lg mr-2">✅</span>
          <span className="text-sm text-primary-700">Non-Veg OK</span>
        </div>
        <div className="flex items-center">
          <span className="text-lg mr-2">❌</span>
          <span className="text-sm text-vegOnly-700">Veg Only</span>
        </div>
        <div className="flex items-center">
          <span className="text-lg mr-2">⚠️</span>
          <span className="text-sm text-conditional-700">Conditional</span>
        </div>
      </div>

      {/* Calendar Grid */}
      <div className="grid grid-cols-7 gap-1">
        {/* Day headers */}
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
          <div key={day} className="p-2 text-center text-sm font-medium text-gray-500">
            {day}
          </div>
        ))}
        
        {/* Calendar days */}
        {calendarDays.map((date, index) => {
          const dayStatus = getDayStatus(date)
          const isCurrentMonth = date.getMonth() === currentMonth.getMonth()
          const isToday = isTodayHelper(date)
          const isSelected = selectedDate && isSameDayHelper(date, selectedDate)
          
          return (
            <button
              key={index}
              onClick={() => setSelectedDate(date)}
              className={`
                p-2 h-12 border rounded-lg text-sm font-medium transition-colors
                ${isCurrentMonth ? 'text-gray-900' : 'text-gray-400'}
                ${isToday ? 'ring-2 ring-primary-500' : ''}
                ${isSelected ? 'ring-2 ring-blue-500' : ''}
                ${isCurrentMonth ? dayStatus.color : 'bg-gray-50 border-gray-200'}
                hover:bg-opacity-80
              `}
            >
              <div className="flex flex-col items-center">
                <span>{date.getDate()}</span>
                {isCurrentMonth && (
                  <span className="text-xs">{dayStatus.icon}</span>
                )}
              </div>
            </button>
          )
        })}
      </div>

      {/* Selected Date Info */}
      {selectedDate && (
        <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h3 className="font-medium text-blue-900 mb-2">
            {selectedDate.toLocaleDateString('en-US', { 
              weekday: 'long', 
              month: 'long', 
              day: 'numeric',
              year: 'numeric'
            })}
          </h3>
          {(() => {
            const status = getDayStatus(selectedDate)
            return (
              <div className="flex items-center">
                <span className="text-lg mr-2">{status.icon}</span>
                <span className="text-sm text-blue-800">
                  {status.restriction === RestrictionType.VEG_ONLY ? 'Vegetarian Only' :
                   status.restriction === RestrictionType.CONDITIONAL ? 'Conditional Restrictions' :
                   'Non-Vegetarian Allowed'}
                </span>
              </div>
            )
          })()}
        </div>
      )}
      
      {loading && (
        <div className="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
        </div>
      )}
    </div>
  )
}