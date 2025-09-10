'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase'
import { Button } from '@/components/ui/Button'
import { X, Plus, Trash2 } from 'lucide-react'
import { RestrictionType, DietEvent } from '@/types'
import { formatDate } from '@/utils/dateUtils'

interface DateEditorModalProps {
  date: Date
  userId: string
  onClose: () => void
  onSave: () => void
}

interface ManualOverride {
  id?: string
  date: string
  restriction: RestrictionType
  reason: string
  notes: string
}

export default function DateEditorModal({ date, userId, onClose, onSave }: DateEditorModalProps) {
  const [events, setEvents] = useState<DietEvent[]>([])
  const [override, setOverride] = useState<ManualOverride | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  
  const supabase = createClient()
  const dateStr = formatDate(date)

  useEffect(() => {
    loadDateData()
  }, [])

  const loadDateData = async () => {
    try {
      setLoading(true)
      
      // Load events for this date
      const { data: eventsData } = await supabase
        .from('diet_events')
        .select('*')
        .eq('user_id', userId)
        .eq('date', dateStr)
      
      // Load manual override for this date
      const { data: overrideData } = await supabase
        .from('manual_overrides')
        .select('*')
        .eq('user_id', userId)
        .eq('date', dateStr)
        .single()
      
      setEvents(eventsData || [])
      if (overrideData) {
        setOverride({
          id: overrideData.id,
          date: overrideData.date,
          restriction: overrideData.restriction as RestrictionType,
          reason: overrideData.reason || '',
          notes: overrideData.notes || ''
        })
      }
    } catch (error) {
      console.error('Error loading date data:', error)
    } finally {
      setLoading(false)
    }
  }

  const saveOverride = async () => {
    if (!override) return
    
    try {
      setSaving(true)
      
      const overrideData = {
        user_id: userId,
        date: dateStr,
        restriction: override.restriction,
        reason: override.reason,
        notes: override.notes
      }
      
      if (override.id) {
        const { error } = await supabase
          .from('manual_overrides')
          .update(overrideData)
          .eq('id', override.id)
        
        if (error) throw error
      } else {
        const { error } = await supabase
          .from('manual_overrides')
          .insert([overrideData])
        
        if (error) throw error
      }
      
      onSave()
      onClose()
    } catch (error) {
      console.error('Error saving override:', error)
      alert('Error saving override. Please try again.')
    } finally {
      setSaving(false)
    }
  }

  const deleteOverride = async () => {
    if (!override?.id) return
    
    if (!confirm('Are you sure you want to remove this override?')) return
    
    try {
      const { error } = await supabase
        .from('manual_overrides')
        .delete()
        .eq('id', override.id)
      
      if (error) throw error
      
      setOverride(null)
      onSave()
      onClose()
    } catch (error) {
      console.error('Error deleting override:', error)
      alert('Error deleting override. Please try again.')
    }
  }

  const createOverride = () => {
    setOverride({
      date: dateStr,
      restriction: RestrictionType.VEG_ONLY,
      reason: '',
      notes: ''
    })
  }

  const getRestrictionBadgeClass = (restriction: string) => {
    switch (restriction) {
      case RestrictionType.VEG_ONLY:
        return 'bg-vegOnly-100 text-vegOnly-800'
      case RestrictionType.CONDITIONAL:
        return 'bg-conditional-100 text-conditional-800'
      default:
        return 'bg-primary-100 text-primary-800'
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-semibold text-gray-900">
            Edit {date.toLocaleDateString('en-US', { 
              weekday: 'long', 
              month: 'long', 
              day: 'numeric',
              year: 'numeric'
            })}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
          </div>
        ) : (
          <div className="p-6 space-y-6">
            {/* Existing Events */}
            {events.length > 0 && (
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-3">Events on this day</h3>
                <div className="space-y-2">
                  {events.map(event => (
                    <div key={event.id} className="p-3 bg-gray-50 rounded-lg border">
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="font-medium">{event.name}</div>
                          <div className="text-sm text-gray-600">{event.category}</div>
                          {event.reason && (
                            <div className="text-xs text-gray-500 mt-1">{event.reason}</div>
                          )}
                        </div>
                        <div className={`px-2 py-1 rounded text-xs font-medium ${getRestrictionBadgeClass(event.restriction)}`}>
                          {event.restriction === RestrictionType.VEG_ONLY ? 'Veg Only' :
                           event.restriction === RestrictionType.CONDITIONAL ? 'Conditional' : 'Non-Veg OK'}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Manual Override */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-lg font-medium text-gray-900">Manual Override</h3>
                {!override && (
                  <Button
                    onClick={createOverride}
                    size="sm"
                    className="btn-primary"
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    Add Override
                  </Button>
                )}
              </div>
              
              {override ? (
                <div className="space-y-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                  <div className="flex items-center justify-between">
                    <div className="text-sm font-medium text-yellow-800">
                      Override active - this will take priority over events and weekly rules
                    </div>
                    <Button
                      onClick={deleteOverride}
                      size="sm"
                      variant="outline"
                      className="text-red-600 hover:text-red-700"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                  
                  <div className="grid grid-cols-1 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Dietary Restriction *
                      </label>
                      <select
                        value={override.restriction}
                        onChange={(e) => setOverride({ ...override, restriction: e.target.value as RestrictionType })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                      >
                        <option value={RestrictionType.VEG_ONLY}>Vegetarian Only</option>
                        <option value={RestrictionType.CONDITIONAL}>Conditional</option>
                        <option value={RestrictionType.NON_VEG_ALLOWED}>Non-Veg Allowed</option>
                      </select>
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Reason *
                      </label>
                      <input
                        type="text"
                        value={override.reason}
                        onChange={(e) => setOverride({ ...override, reason: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                        placeholder="Why this override is needed"
                        required
                      />
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Additional Notes
                      </label>
                      <textarea
                        value={override.notes}
                        onChange={(e) => setOverride({ ...override, notes: e.target.value })}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                        rows={2}
                        placeholder="Optional additional information"
                      />
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-center py-8 text-gray-500">
                  <div className="text-sm">
                    No manual override set. The day will follow normal event and weekly rule patterns.
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Footer */}
        <div className="flex justify-end space-x-3 p-6 border-t bg-gray-50">
          <Button
            variant="outline"
            onClick={onClose}
          >
            Cancel
          </Button>
          {override && (
            <Button
              onClick={saveOverride}
              disabled={saving || !override.reason.trim()}
              className="btn-primary"
            >
              {saving ? 'Saving...' : 'Save Override'}
            </Button>
          )}
        </div>
      </div>
    </div>
  )
}