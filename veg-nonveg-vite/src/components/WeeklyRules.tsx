interface WeeklyRulesProps {
  userId: string
}

export default function WeeklyRules({ userId }: WeeklyRulesProps) {
  return (
    <div className="card">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Weekly Rules</h2>
      <div className="text-center text-gray-600 py-12">
        <p className="text-lg mb-4">Weekly rules configuration coming soon...</p>
        <p className="text-sm">Here you'll be able to set up your weekly dietary restrictions and preferences.</p>
      </div>
    </div>
  )
}