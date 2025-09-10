import { useEffect, useState } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { User } from '@supabase/supabase-js'
import { createSupabaseClient } from '@/lib/supabase'
import AuthComponent from '@/components/Auth'
import Dashboard from '@/components/Dashboard'
import LoadingSpinner from '@/components/LoadingSpinner'

function App() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const supabase = createSupabaseClient()

  useEffect(() => {
    // Check current user
    const getUser = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      setUser(user)
      setLoading(false)
    }

    getUser()

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        setUser(session?.user ?? null)
        setLoading(false)
      }
    )

    return () => subscription.unsubscribe()
  }, [supabase.auth])

  if (loading) {
    return <LoadingSpinner />
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Routes>
        <Route 
          path="/" 
          element={user ? <Dashboard user={user} /> : <AuthComponent />} 
        />
        <Route 
          path="/auth/callback" 
          element={<LoadingSpinner />} 
        />
        <Route 
          path="*" 
          element={<Navigate to="/" replace />} 
        />
      </Routes>
    </div>
  )
}

export default App