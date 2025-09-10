interface EventManagerProps {
  userId: string
}

export default function EventManager({ userId }: EventManagerProps) {
  return (
    <div className="card">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Event Manager</h2>
      <div className="text-center text-gray-600 py-12">
        <p className="text-lg mb-4">Event management functionality coming soon...</p>
        <p className="text-sm">Here you'll be able to add, edit, and manage your dietary events and festivals.</p>
      </div>
    </div>
  )
}