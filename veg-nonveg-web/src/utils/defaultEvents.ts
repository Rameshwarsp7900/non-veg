import { DietEvent, EventCategory, RestrictionType } from '@/types';

export const getDefaultEvents = (year: number, userId: string): Partial<DietEvent>[] => {
  const events: Partial<DietEvent>[] = [];

  // Major Hindu Festivals
  events.push(
    // Ganesh Chaturthi
    {
      name: 'Ganesh Chaturthi',
      date: `${year}-08-27`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: '10-day festival celebrating Lord Ganesha',
      reason: 'Ganesh Chaturthi - Sacred festival, only vegetarian offerings',
      is_recurring: true,
      user_id: userId,
    },

    // Navratri (9 days)
    ...Array.from({ length: 9 }, (_, i) => ({
      name: `Navratri Day ${i + 1}`,
      date: `${year}-10-${String(1 + i).padStart(2, '0')}`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Nine nights festival dedicated to Goddess Durga',
      reason: 'Navratri - Sacred period, strict vegetarian diet',
      is_recurring: true,
      user_id: userId,
    })),

    // Diwali
    {
      name: 'Diwali',
      date: `${year}-11-12`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Festival of Lights',
      reason: 'Diwali - Most auspicious festival, vegetarian diet preferred',
      is_recurring: true,
      user_id: userId,
    },

    // Karva Chauth
    {
      name: 'Karva Chauth',
      date: `${year}-11-01`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Fasting festival for married women',
      reason: 'Karva Chauth - Fasting day, vegetarian diet only',
      is_recurring: true,
      user_id: userId,
    },

    // Holi
    {
      name: 'Holi',
      date: `${year}-03-13`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.CONDITIONAL,
      description: 'Festival of Colors',
      reason: 'Holi - Celebration day, some families prefer vegetarian',
      is_recurring: true,
      user_id: userId,
    },

    // Janmashtami
    {
      name: 'Janmashtami',
      date: `${year}-08-15`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Birthday of Lord Krishna',
      reason: 'Janmashtami - Lord Krishna\'s birthday, strict vegetarian',
      is_recurring: true,
      user_id: userId,
    },

    // Ram Navami
    {
      name: 'Ram Navami',
      date: `${year}-04-10`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Birthday of Lord Rama',
      reason: 'Ram Navami - Lord Rama\'s birthday, vegetarian diet',
      is_recurring: true,
      user_id: userId,
    },

    // Makar Sankranti
    {
      name: 'Makar Sankranti',
      date: `${year}-01-14`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Harvest festival',
      reason: 'Makar Sankranti - Harvest festival, traditional vegetarian feast',
      is_recurring: true,
      user_id: userId,
    },

    // Maha Shivratri
    {
      name: 'Maha Shivratri',
      date: `${year}-02-18`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Great night of Lord Shiva',
      reason: 'Maha Shivratri - Fasting day for Lord Shiva, vegetarian only',
      is_recurring: true,
      user_id: userId,
    }
  );

  // Monthly Ekadashi and Purnima
  for (let month = 1; month <= 12; month++) {
    // Ekadashi (11th day)
    events.push({
      name: 'Ekadashi',
      date: `${year}-${String(month).padStart(2, '0')}-11`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Ekadashi fasting day',
      reason: 'Ekadashi - Traditional fasting day, only sattvic food allowed',
      is_recurring: true,
      user_id: userId,
    });

    // Purnima (15th day - Full Moon)
    events.push({
      name: 'Purnima',
      date: `${year}-${String(month).padStart(2, '0')}-15`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Full Moon day',
      reason: 'Purnima - Full moon day, vegetarian diet preferred',
      is_recurring: true,
      user_id: userId,
    });

    // Sankashti Chaturthi (19th day)
    events.push({
      name: 'Sankashti Chaturthi',
      date: `${year}-${String(month).padStart(2, '0')}-19`,
      category: EventCategory.FESTIVAL,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Monthly Ganesha fasting day',
      reason: 'Sankashti Chaturthi - Lord Ganesha fasting day, vegetarian only',
      is_recurring: true,
      user_id: userId,
    });
  }

  // Sample eclipses
  events.push(
    {
      name: 'Solar Eclipse',
      date: `${year}-04-08`,
      category: EventCategory.ECLIPSE,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Solar eclipse - inauspicious for eating',
      reason: 'Solar Eclipse - Traditional restriction on food consumption during eclipse',
      is_recurring: false,
      user_id: userId,
    },
    {
      name: 'Lunar Eclipse',
      date: `${year}-10-14`,
      category: EventCategory.ECLIPSE,
      restriction: RestrictionType.VEG_ONLY,
      description: 'Lunar eclipse - inauspicious for eating',
      reason: 'Lunar Eclipse - Traditional restriction on food consumption during eclipse',
      is_recurring: false,
      user_id: userId,
    }
  );

  return events;
};

export const getDefaultWeeklyRules = (userId: string) => {
  return [
    {
      weekday: 2, // Tuesday
      restriction: RestrictionType.VEG_ONLY,
      reason: "Tuesday - Hanuman's day (traditional restriction)",
      is_active: true,
      user_id: userId,
    },
    {
      weekday: 6, // Saturday
      restriction: RestrictionType.VEG_ONLY,
      reason: "Saturday - Hanuman's day (traditional restriction)",
      is_active: true,
      user_id: userId,
    },
  ];
};