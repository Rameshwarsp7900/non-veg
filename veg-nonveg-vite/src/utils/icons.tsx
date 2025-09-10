import { RestrictionType } from '@/types'

// Icon mapping for diet restrictions
export const getDietIcon = (restriction: RestrictionType): string => {
  switch (restriction) {
    case RestrictionType.VEG_ONLY:
      return '/icons/veg-only.svg'
    case RestrictionType.CONDITIONAL:
      return '/icons/conditional.svg'
    case RestrictionType.NON_VEG_ALLOWED:
    default:
      return '/icons/non-veg-allowed.svg'
  }
}

// Icon component props interface
export interface DietIconProps {
  restriction: RestrictionType
  size?: number
  className?: string
  alt?: string
}

// Reusable icon component
export const DietIcon: React.FC<DietIconProps> = ({ 
  restriction, 
  size = 24, 
  className = '',
  alt
}) => {
  const iconSrc = getDietIcon(restriction)
  const altText = alt || `${restriction} diet icon`
  
  return (
    <img 
      src={iconSrc} 
      alt={altText}
      width={size} 
      height={size}
      className={className}
    />
  )
}

// Additional diet-related icons
export const getVegetarianIcon = () => '/icons/vegetarian.svg'
export const getNonVegetarianIcon = () => '/icons/non-vegetarian.svg'
export const getCalendarIcon = () => '/icons/calendar.svg'

// Generic icon component for other diet-related icons
export interface GenericIconProps {
  src: string
  size?: number
  className?: string
  alt: string
}

export const GenericIcon: React.FC<GenericIconProps> = ({ 
  src, 
  size = 24, 
  className = '',
  alt
}) => {
  return (
    <img 
      src={src} 
      alt={alt}
      width={size} 
      height={size}
      className={className}
    />
  )
}