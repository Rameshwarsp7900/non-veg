'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase'
import { Button } from '@/components/ui/Button'
import { Save, RotateCcw } from 'lucide-react'
import { RestrictionType } from '@/types'

interface WeeklyRulesProps {
  userId: string
}

interface WeeklyRule {
  id?: string
  weekday: number
  restriction: RestrictionType
  reason: string
  is_active: boolean
}

const WEEKDAYS = [
  { id: 1, name: 'Monday', shortName: 'Mon' },
  { id: 2, name: 'Tuesday', shortName: 'Tue' },
  { id: 3, name: 'Wednesday', shortName: 'Wed' },
  { id: 4, name: 'Thursday', shortName: 'Thu' },
  { id: 5, name: 'Friday', shortName: 'Fri' },
  { id: 6, name: 'Saturday', shortName: 'Sat' },
  { id: 7, name: 'Sunday', shortName: 'Sun' }
]

const DEFAULT_RULES: Record<number, WeeklyRule> = {
  1: { weekday: 1, restriction: RestrictionType.NON_VEG_ALLOWED, reason: '', is_active: false },
  2: { weekday: 2, restriction: RestrictionType.VEG_ONLY, reason: 'Traditional Hanuman day restriction', is_active: true },
  3: { weekday: 3, restriction: RestrictionType.NON_VEG_ALLOWED, reason: '', is_active: false },
  4: { weekday: 4, restriction: RestrictionType.NON_VEG_ALLOWED, reason: '', is_active: false },
  5: { weekday: 5, restriction: RestrictionType.NON_VEG_ALLOWED, reason: '', is_active: false },
  6: { weekday: 6, restriction: RestrictionType.VEG_ONLY, reason: 'Traditional Hanuman day restriction', is_active: true },
  7: { weekday: 7, restriction: RestrictionType.NON_VEG_ALLOWED, reason: '', is_active: false }
}

export default function WeeklyRules({ userId }: WeeklyRulesProps) {
  const [rules, setRules] = useState<Record<number, WeeklyRule>>(DEFAULT_RULES)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [hasChanges, setHasChanges] = useState(false)
  
  const supabase = createClient()

  useEffect(() => {
    loadRules()
  }, [userId])

  const loadRules = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('weekly_rules')
        .select('*')
        .eq('user_id', userId)
      
      if (error) throw error
      
      const loadedRules = { ...DEFAULT_RULES }
      data?.forEach(rule => {
        loadedRules[rule.weekday] = {
          id: rule.id,
          weekday: rule.weekday,
          restriction: rule.restriction as RestrictionType,
          reason: rule.reason || '',
          is_active: rule.is_active
        }
      })
      
      setRules(loadedRules)
    } catch (error) {
      console.error('Error loading weekly rules:', error)
    } finally {
      setLoading(false)
    }
  }

  const updateRule = (weekday: number, updates: Partial<WeeklyRule>) => {
    setRules(prev => ({
      ...prev,
      [weekday]: { ...prev[weekday], ...updates }
    }))
    setHasChanges(true)
  }

  const saveRules = async () => {
    try {
      setSaving(true)
      
      for (const rule of Object.values(rules)) {
        const ruleData = {
          user_id: userId,
          weekday: rule.weekday,
          restriction: rule.restriction,
          reason: rule.reason,
          is_active: rule.is_active
        }
        
        if (rule.id) {
          // Update existing rule
          const { error } = await supabase
            .from('weekly_rules')
            .update(ruleData)
            .eq('id', rule.id)
          
          if (error) {
            console.error('Error updating weekly rule:', error)
            throw new Error(`Failed to update rule for weekday ${rule.weekday}: ${error.message}`)
          }
        } else {
          // Insert new rule
          const { error } = await supabase
            .from('weekly_rules')
            .insert([ruleData])
          
          if (error) {
            console.error('Error inserting weekly rule:', error)
            throw new Error(`Failed to create rule for weekday ${rule.weekday}: ${error.message}`)
          }
        }
      }
      
      await loadRules()
      setHasChanges(false)
      alert('Weekly rules saved successfully!')
    } catch (error: any) {
      console.error('Error saving weekly rules:', error)
      
      let errorMessage = 'Error saving weekly rules. '
      
      if (error.message.includes('relation "weekly_rules" does not exist')) {
        errorMessage += 'Database tables are not set up. Please run the database schema setup in your Supabase dashboard.'
      } else if (error.message.includes('JWT')) {
        errorMessage += 'Authentication error. Please try logging out and logging back in.'
      } else if (error.message.includes('RLS')) {
        errorMessage += 'Permission error. Please check your database security settings.'
      } else {
        errorMessage += error.message || 'Please try again.'
      }
      
      alert(errorMessage)
    } finally {
      setSaving(false)
    }
  }

  const resetToDefaults = () => {
    if (confirm('Are you sure you want to reset to default rules? This will override your current settings.')) {
      setRules(DEFAULT_RULES)
      setHasChanges(true)
    }
  }

  const getRestrictionColor = (restriction: RestrictionType) => {
    switch (restriction) {
      case RestrictionType.VEG_ONLY:
        return 'border-vegOnly-300 bg-vegOnly-50 text-vegOnly-800'
      case RestrictionType.CONDITIONAL:
        return 'border-conditional-300 bg-conditional-50 text-conditional-800'
      default:
        return 'border-primary-300 bg-primary-50 text-primary-800'
    }
  }

  const getRestrictionIcon = (restriction: RestrictionType) => {
    switch (restriction) {
      case RestrictionType.VEG_ONLY:
        return '❌'
      case RestrictionType.CONDITIONAL:
        return '⚠️'
      default:
        return '✅'
    }
  }

  return (
    <div className="card">
      <div className="card-header">
        <div className="flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Weekly Rules</h2>
            <p className="text-gray-600">Set recurring dietary restrictions for specific days of the week</p>
          </div>
          <div className="flex space-x-2">
            <Button
              variant="outline"
              onClick={resetToDefaults}
              disabled={loading || saving}
            >
              <RotateCcw className="h-4 w-4 mr-2" />
              Reset to Defaults
            </Button>
            <Button
              onClick={saveRules}
              disabled={!hasChanges || loading || saving}
              className="btn-primary"
            >
              <Save className="h-4 w-4 mr-2" />
              {saving ? 'Saving...' : 'Save Rules'}
            </Button>
          </div>
        </div>
      </div>

      {loading ? (
        <div className="text-center py-8">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
        </div>
      ) : (
        <div className="space-y-4">
          {/* Legend */}
          <div className="p-4 bg-gray-50 rounded-lg">
            <h3 className="text-sm font-medium text-gray-900 mb-3">Legend</h3>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
              <div className="flex items-center">
                <span className="text-lg mr-2">✅</span>
                <span className="text-primary-700">Non-Vegetarian Allowed</span>
              </div>
              <div className="flex items-center">
                <span className="text-lg mr-2">❌</span>
                <span className="text-vegOnly-700">Vegetarian Only</span>
              </div>
              <div className="flex items-center">
                <span className="text-lg mr-2">⚠️</span>
                <span className="text-conditional-700">Conditional Restrictions</span>
              </div>
            </div>
          </div>

          {/* Rules for each day */}
          <div className="grid gap-4">
            {WEEKDAYS.map(day => {
              const rule = rules[day.id]
              return (
                <div
                  key={day.id}
                  className={`border rounded-lg p-4 transition-colors ${
                    rule.is_active ? getRestrictionColor(rule.restriction) : 'border-gray-200 bg-gray-50'
                  }`}
                >
                  <div className="flex items-start space-x-4">
                    {/* Day name and active toggle */}
                    <div className="flex-shrink-0">
                      <div className="flex items-center space-x-3">
                        <div className="text-lg font-medium text-gray-900">
                          {day.name}
                        </div>
                        <div className="flex items-center">
                          <input
                            type="checkbox"
                            id={`active-${day.id}`}
                            checked={rule.is_active}
                            onChange={(e) => updateRule(day.id, { is_active: e.target.checked })}
                            className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                          />
                          <label htmlFor={`active-${day.id}`} className="ml-2 text-sm text-gray-700">
                            Active
                          </label>
                        </div>
                      </div>
                    </div>

                    {/* Restriction selection */}
                    <div className="flex-1">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Dietary Restriction
                          </label>
                          <div className="flex items-center space-x-2">
                            <span className="text-lg">{getRestrictionIcon(rule.restriction)}</span>
                            <select
                              value={rule.restriction}
                              onChange={(e) => updateRule(day.id, { restriction: e.target.value as RestrictionType })}
                              disabled={!rule.is_active}
                              className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 disabled:bg-gray-100 disabled:text-gray-500"
                            >
                              <option value={RestrictionType.NON_VEG_ALLOWED}>Non-Vegetarian Allowed</option>
                              <option value={RestrictionType.VEG_ONLY}>Vegetarian Only</option>
                              <option value={RestrictionType.CONDITIONAL}>Conditional</option>
                            </select>
                          </div>
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Reason
                          </label>
                          <input
                            type="text"
                            value={rule.reason}
                            onChange={(e) => updateRule(day.id, { reason: e.target.value })}
                            disabled={!rule.is_active}
                            placeholder={rule.is_active ? "Why this restriction applies..." : "Rule is inactive"}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 disabled:bg-gray-100 disabled:text-gray-500"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>

          {/* Preset Templates */}
          <div className="mt-8 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <h3 className="text-sm font-medium text-blue-900 mb-3">Quick Templates</h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  setRules({
                    ...DEFAULT_RULES,
                    2: { ...DEFAULT_RULES[2], is_active: true },
                    6: { ...DEFAULT_RULES[6], is_active: true }
                  })
                  setHasChanges(true)
                }}
                className="text-left justify-start"
              >
                <div>
                  <div className="font-medium">Traditional Hindu</div>
                  <div className="text-xs text-gray-600">Tuesday & Saturday veg-only</div>
                </div>
              </Button>
              
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  const allVeg = { ...DEFAULT_RULES }
                  Object.keys(allVeg).forEach(day => {
                    allVeg[parseInt(day)] = {
                      ...allVeg[parseInt(day)],
                      restriction: RestrictionType.VEG_ONLY,
                      reason: 'Personal preference',
                      is_active: true
                    }
                  })
                  setRules(allVeg)
                  setHasChanges(true)
                }}
                className="text-left justify-start"
              >
                <div>
                  <div className="font-medium">Full Vegetarian</div>
                  <div className="text-xs text-gray-600">All days veg-only</div>
                </div>
              </Button>
            </div>
          </div>

          {hasChanges && (
            <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p className="text-sm text-yellow-800">
                ⚠️ You have unsaved changes. Don't forget to save your weekly rules!
              </p>
            </div>
          )}
        </div>
      )}
    </div>
  )
}