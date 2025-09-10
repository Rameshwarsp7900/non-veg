import { DietIcon, GenericIcon, getVegetarianIcon, getNonVegetarianIcon } from '@/utils/icons'
import { RestrictionType } from '@/types'

interface TodayStatusProps {
  status: {
    restriction: RestrictionType
    reason: string
    statusText: string
  }
}

export default function TodayStatus({ status }: TodayStatusProps) {
  const getGradientClass = () => {
    switch (status.restriction) {
      case RestrictionType.VEG_ONLY:
        return 'from-vegOnly-400 to-vegOnly-600'
      case RestrictionType.CONDITIONAL:
        return 'from-conditional-400 to-conditional-600'
      default:
        return 'from-primary-400 to-primary-600'
    }
  }

  return (
    <div className="card">
      <div className={`rounded-lg bg-gradient-to-r ${getGradientClass()} p-6 text-white`}>
        <div className="flex items-center">
          <div className="mr-4">
            <DietIcon restriction={status.restriction} size={48} className="filter brightness-0 invert" />
          </div>
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
            {status.restriction === RestrictionType.VEG_ONLY ? (
              <>
                <GenericIcon 
                  src={getVegetarianIcon()} 
                  size={20} 
                  alt="Vegetarian" 
                  className="mr-2 filter brightness-0 invert" 
                />
                Vegetarian meals recommended
              </>
            ) : status.restriction === RestrictionType.CONDITIONAL ? (
              <>
                <DietIcon 
                  restriction={RestrictionType.CONDITIONAL} 
                  size={20} 
                  className="mr-2 filter brightness-0 invert" 
                />
                Check specific restrictions
              </>
            ) : (
              <>
                <GenericIcon 
                  src={getNonVegetarianIcon()} 
                  size={20} 
                  alt="Non-vegetarian allowed" 
                  className="mr-2 filter brightness-0 invert" 
                />
                All food types allowed
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}