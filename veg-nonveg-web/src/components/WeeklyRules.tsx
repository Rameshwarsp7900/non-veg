interface WeeklyRulesProps {
  userId: string
}

export default function WeeklyRules({ userId }: WeeklyRulesProps) {
  return (
    <div className="card">
      <div className="card-header">
        <h2 className="text-2xl font-bold text-gray-900">Weekly Rules</h2>
        <p className="text-gray-600">Set recurring dietary restrictions for specific days</p>
      </div>
      
      <div className="text-center py-12">
        <div className="text-6xl mb-4">📆</div>
        <h3 className="text-xl font-medium text-gray-900 mb-2">Coming Soon</h3>
        <p className="text-gray-600">
          Weekly rules management will be available soon. 
          Set traditional patterns like Tuesday/Saturday restrictions.
        </p>
      </div>
    </div>
  )
}