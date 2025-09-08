interface TodayStatusProps {
  status: {
    restriction: string
    reason: string
    iconText: string
    statusText: string
  }
}

export default function TodayStatus({ status }: TodayStatusProps) {
  const getGradientClass = () => {
    switch (status.restriction) {
      case 'veg_only':
        return 'from-vegOnly-400 to-vegOnly-600'
      case 'conditional':
        return 'from-conditional-400 to-conditional-600'
      default:
        return 'from-primary-400 to-primary-600'
    }
  }

  return (
    <div className="card">
      <div className={`rounded-lg bg-gradient-to-r ${getGradientClass()} p-6 text-white`}>
        <div className="flex items-center">
          <div className="text-4xl mr-4">{status.iconText}</div>
          <div className="flex-1">
            <h2 className="text-2xl font-bold mb-2">
              Today - {new Date().toLocaleDateString('en-US', { 
                weekday: 'long', 
                month: 'long', 
                day: 'numeric' 
              })}
            </h2>
            <p className="text-xl opacity-90">{status.statusText}</p>
          </div>
        </div>
        
        <div className="mt-4 p-4 bg-white bg-opacity-20 rounded-lg">
          <p className="text-sm font-medium mb-1">Reason:</p>
          <p className="text-sm">{status.reason}</p>
        </div>
        
        <div className="mt-4 flex justify-between items-center">
          <div className="flex items-center text-sm">
            {status.restriction === 'veg_only' ? (
              <>
                <span className="mr-2">🌱</span>
                Vegetarian meals recommended
              </>
            ) : status.restriction === 'conditional' ? (
              <>
                <span className="mr-2">⚠️</span>
                Check specific restrictions
              </>
            ) : (
              <>
                <span className="mr-2">🍽️</span>
                All food types allowed
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}