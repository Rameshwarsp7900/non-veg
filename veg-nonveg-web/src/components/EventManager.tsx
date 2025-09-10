'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase'
import { Button } from '@/components/ui/Button'
import { Plus, Edit, Trash2, Calendar, Filter } from 'lucide-react'
import { DietEvent, RestrictionType } from '@/types'
import { formatDate } from '@/utils/dateUtils'

interface EventManagerProps {
  userId: string
}

interface EventForm {
  name: string
  date: string
  category: string
  restriction: RestrictionType
  description: string
  reason: string
  is_recurring: boolean
}

const initialForm: EventForm = {
  name: '',
  date: '',
  category: 'festival',
  restriction: RestrictionType.VEG_ONLY,
  description: '',
  reason: '',
  is_recurring: false
}

export default function EventManager({ userId }: EventManagerProps) {
  const [events, setEvents] = useState<DietEvent[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingEvent, setEditingEvent] = useState<DietEvent | null>(null)
  const [form, setForm] = useState<EventForm>(initialForm)
  const [filter, setFilter] = useState<string>('all')
  const [searchTerm, setSearchTerm] = useState('')
  
  const supabase = createClient()

  useEffect(() => {
    loadEvents()
  }, [userId])

  const loadEvents = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('diet_events')
        .select('*')
        .eq('user_id', userId)
        .order('date', { ascending: true })
      
      if (error) throw error
      setEvents(data || [])
    } catch (error) {
      console.error('Error loading events:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    try {
      const eventData = {
        ...form,
        user_id: userId,
        created_by: userId
      }

      if (editingEvent) {
        const { error } = await supabase
          .from('diet_events')
          .update(eventData)
          .eq('id', editingEvent.id)
        
        if (error) throw error
      } else {
        const { error } = await supabase
          .from('diet_events')
          .insert([eventData])
        
        if (error) throw error
      }

      await loadEvents()
      resetForm()
    } catch (error) {
      console.error('Error saving event:', error)
      alert('Error saving event. Please try again.')
    }
  }

  const handleEdit = (event: DietEvent) => {
    setEditingEvent(event)
    setForm({
      name: event.name,
      date: event.date,
      category: event.category,
      restriction: event.restriction as RestrictionType,
      description: event.description || '',
      reason: event.reason || '',
      is_recurring: event.is_recurring
    })
    setShowForm(true)
  }

  const handleDelete = async (eventId: string) => {
    if (!confirm('Are you sure you want to delete this event?')) return
    
    try {
      const { error } = await supabase
        .from('diet_events')
        .delete()
        .eq('id', eventId)
      
      if (error) throw error
      await loadEvents()
    } catch (error) {
      console.error('Error deleting event:', error)
      alert('Error deleting event. Please try again.')
    }
  }

  const resetForm = () => {
    setForm(initialForm)
    setEditingEvent(null)
    setShowForm(false)
  }

  const filteredEvents = events.filter(event => {
    const matchesFilter = filter === 'all' || event.category === filter
    const matchesSearch = event.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         event.description?.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesFilter && matchesSearch
  })

  const getRestrictionColor = (restriction: string) => {
    switch (restriction) {
      case RestrictionType.VEG_ONLY:
        return 'bg-vegOnly-100 text-vegOnly-800 border-vegOnly-200'
      case RestrictionType.CONDITIONAL:
        return 'bg-conditional-100 text-conditional-800 border-conditional-200'
      default:
        return 'bg-primary-100 text-primary-800 border-primary-200'
    }
  }

  const getRestrictionIcon = (restriction: string) => {
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
            <h2 className="text-2xl font-bold text-gray-900">Event Manager</h2>
            <p className="text-gray-600">Manage festivals, special days, and personal events</p>
          </div>
          <Button
            onClick={() => setShowForm(!showForm)}
            className="btn-primary"
          >
            <Plus className="h-4 w-4 mr-2" />
            Add Event
          </Button>
        </div>
      </div>

      {/* Add/Edit Form */}
      {showForm && (
        <div className="mb-6 p-6 bg-gray-50 rounded-lg border">
          <h3 className="text-lg font-medium text-gray-900 mb-4">
            {editingEvent ? 'Edit Event' : 'Add New Event'}
          </h3>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Event Name *
                </label>
                <input
                  type="text"
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="e.g., Diwali, Ekadashi, Personal Fast"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Date *
                </label>
                <input
                  type="date"
                  required
                  value={form.date}
                  onChange={(e) => setForm({ ...form, date: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Category
                </label>
                <select
                  value={form.category}
                  onChange={(e) => setForm({ ...form, category: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="festival">Festival</option>
                  <option value="fast">Fast/Vrat</option>
                  <option value="eclipse">Eclipse</option>
                  <option value="personal">Personal</option>
                  <option value="religious">Religious</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Dietary Restriction *
                </label>
                <select
                  value={form.restriction}
                  onChange={(e) => setForm({ ...form, restriction: e.target.value as RestrictionType })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value={RestrictionType.VEG_ONLY}>Vegetarian Only</option>
                  <option value={RestrictionType.CONDITIONAL}>Conditional</option>
                  <option value={RestrictionType.NON_VEG_ALLOWED}>Non-Veg Allowed</option>
                </select>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Description
              </label>
              <textarea
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                rows={2}
                placeholder="Optional description of the event"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Reason for Restriction
              </label>
              <textarea
                value={form.reason}
                onChange={(e) => setForm({ ...form, reason: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
                rows={2}
                placeholder="Why this dietary restriction applies"
              />
            </div>
            
            <div className="flex items-center">
              <input
                type="checkbox"
                id="recurring"
                checked={form.is_recurring}
                onChange={(e) => setForm({ ...form, is_recurring: e.target.checked })}
                className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
              />
              <label htmlFor="recurring" className="ml-2 block text-sm text-gray-700">
                Recurring yearly (e.g., for festivals)
              </label>
            </div>
            
            <div className="flex space-x-3">
              <Button type="submit" className="btn-primary">
                {editingEvent ? 'Update Event' : 'Add Event'}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={resetForm}
              >
                Cancel
              </Button>
            </div>
          </form>
        </div>
      )}

      {/* Filters and Search */}
      <div className="mb-6 flex flex-col sm:flex-row gap-4">
        <div className="flex-1">
          <input
            type="text"
            placeholder="Search events..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>
        <div className="flex items-center space-x-2">
          <Filter className="h-4 w-4 text-gray-500" />
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">All Categories</option>
            <option value="festival">Festivals</option>
            <option value="fast">Fasts/Vrats</option>
            <option value="eclipse">Eclipses</option>
            <option value="personal">Personal</option>
            <option value="religious">Religious</option>
          </select>
        </div>
      </div>

      {/* Events List */}
      {loading ? (
        <div className="text-center py-8">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
        </div>
      ) : filteredEvents.length === 0 ? (
        <div className="text-center py-12">
          <Calendar className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            {searchTerm || filter !== 'all' ? 'No events found' : 'No events yet'}
          </h3>
          <p className="text-gray-600">
            {searchTerm || filter !== 'all' 
              ? 'Try adjusting your search or filter criteria'
              : 'Add your first event to get started'}
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {filteredEvents.map((event) => (
            <div
              key={event.id}
              className="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors"
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center space-x-3 mb-2">
                    <h3 className="text-lg font-medium text-gray-900">{event.name}</h3>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${
                      getRestrictionColor(event.restriction)
                    }`}>
                      <span className="mr-1">{getRestrictionIcon(event.restriction)}</span>
                      {event.restriction === RestrictionType.VEG_ONLY ? 'Veg Only' :
                       event.restriction === RestrictionType.CONDITIONAL ? 'Conditional' : 'Non-Veg OK'}
                    </span>
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                      {event.category}
                    </span>
                    {event.is_recurring && (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        Yearly
                      </span>
                    )}
                  </div>
                  
                  <div className="text-sm text-gray-600 mb-1">
                    <Calendar className="h-4 w-4 inline mr-2" />
                    {new Date(event.date).toLocaleDateString('en-US', {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}
                  </div>
                  
                  {event.description && (
                    <p className="text-sm text-gray-700 mb-1">{event.description}</p>
                  )}
                  
                  {event.reason && (
                    <p className="text-xs text-gray-600 italic">Reason: {event.reason}</p>
                  )}
                </div>
                
                <div className="flex space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleEdit(event)}
                  >
                    <Edit className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleDelete(event.id)}
                    className="text-red-600 hover:text-red-700 hover:bg-red-50"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}