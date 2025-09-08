interface EventManagerProps {
  userId: string
}

export default function EventManager({ userId }: EventManagerProps) {
  return (
    <div className="card">
      <div className="card-header">
        <h2 className="text-2xl font-bold text-gray-900">Event Manager</h2>
        <p className="text-gray-600">Manage festivals, special days, and personal events</p>
      </div>
      
      <div className="text-center py-12">
        <div className="text-6xl mb-4">🎊</div>
        <h3 className="text-xl font-medium text-gray-900 mb-2">Coming Soon</h3>
        <p className="text-gray-600">
          Event management functionality will be available soon. 
          You can add festivals, eclipses, and personal events here.
        </p>
      </div>
    </div>
  )
}