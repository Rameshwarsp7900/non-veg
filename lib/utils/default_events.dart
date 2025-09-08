import '../models/diet_event.dart';

class DefaultEvents {
  static List<DietEvent> getDefaultEvents() {
    final currentYear = DateTime.now().year;
    final events = <DietEvent>[];

    // Major Hindu Festivals (approximate dates - in real app these would be calculated based on lunar calendar)
    events.addAll(_getHinduFestivals(currentYear));
    events.addAll(_getHinduFestivals(currentYear + 1));
    
    // Weekly recurring events
    events.addAll(_getWeeklyEvents(currentYear));
    
    // Eclipses (sample dates - in real app these would be fetched from astronomical data)
    events.addAll(_getEclipses(currentYear));
    events.addAll(_getEclipses(currentYear + 1));

    return events;
  }

  static List<DietEvent> _getHinduFestivals(int year) {
    return [
      // Ganesh Chaturthi (August/September)
      DietEvent(
        id: 'ganesh_chaturthi_$year',
        name: 'Ganesh Chaturthi',
        date: DateTime(year, 8, 27), // Approximate date
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: '10-day festival celebrating Lord Ganesha',
        reason: 'Ganesh Chaturthi - Sacred festival, only vegetarian offerings',
      ),

      // Navratri (September/October) - 9 days
      ...List.generate(9, (index) => DietEvent(
        id: 'navratri_day_${index + 1}_$year',
        name: 'Navratri Day ${index + 1}',
        date: DateTime(year, 10, 1 + index), // Approximate dates
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Nine nights festival dedicated to Goddess Durga',
        reason: 'Navratri - Sacred period, strict vegetarian diet',
      )),

      // Diwali (October/November)
      DietEvent(
        id: 'diwali_$year',
        name: 'Diwali',
        date: DateTime(year, 11, 12), // Approximate date
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Festival of Lights',
        reason: 'Diwali - Most auspicious festival, vegetarian diet preferred',
      ),

      // Karva Chauth
      DietEvent(
        id: 'karva_chauth_$year',
        name: 'Karva Chauth',
        date: DateTime(year, 11, 1), // Approximate date
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Fasting festival for married women',
        reason: 'Karva Chauth - Fasting day, vegetarian diet only',
      ),

      // Holi
      DietEvent(
        id: 'holi_$year',
        name: 'Holi',
        date: DateTime(year, 3, 13), // Approximate date
        category: EventCategory.festival,
        restriction: RestrictionType.conditional,
        description: 'Festival of Colors',
        reason: 'Holi - Celebration day, some families prefer vegetarian',
      ),

      // Janmashtami
      DietEvent(
        id: 'janmashtami_$year',
        name: 'Janmashtami',
        date: DateTime(year, 8, 15), // Approximate date
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Birthday of Lord Krishna',
        reason: 'Janmashtami - Lord Krishna\'s birthday, strict vegetarian',
      ),

      // Ram Navami
      DietEvent(
        id: 'ram_navami_$year',
        name: 'Ram Navami',
        date: DateTime(year, 4, 10), // Approximate date
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Birthday of Lord Rama',
        reason: 'Ram Navami - Lord Rama\'s birthday, vegetarian diet',
      ),

      // Makar Sankranti
      DietEvent(
        id: 'makar_sankranti_$year',
        name: 'Makar Sankranti',
        date: DateTime(year, 1, 14),
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Harvest festival',
        reason: 'Makar Sankranti - Harvest festival, traditional vegetarian feast',
      ),

      // Maha Shivratri
      DietEvent(
        id: 'maha_shivratri_$year',
        name: 'Maha Shivratri',
        date: DateTime(year, 2, 18), // Approximate date
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Great night of Lord Shiva',
        reason: 'Maha Shivratri - Fasting day for Lord Shiva, vegetarian only',
      ),

      // Ekadashi dates (monthly - sample dates)
      ...List.generate(12, (month) => DietEvent(
        id: 'ekadashi_${month + 1}_$year',
        name: 'Ekadashi',
        date: DateTime(year, month + 1, 11), // 11th day of each month (approximate)
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Ekadashi fasting day',
        reason: 'Ekadashi - Traditional fasting day, only sattvic food allowed',
      )),

      // Purnima (Full Moon) dates
      ...List.generate(12, (month) => DietEvent(
        id: 'purnima_${month + 1}_$year',
        name: 'Purnima',
        date: DateTime(year, month + 1, 15), // 15th day of each month (approximate)
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Full Moon day',
        reason: 'Purnima - Full moon day, vegetarian diet preferred',
      )),
    ];
  }

  static List<DietEvent> _getWeeklyEvents(int year) {
    final events = <DietEvent>[];
    
    // Add Sankashti Chaturthi (4th day after full moon) - monthly
    for (int month = 1; month <= 12; month++) {
      events.add(DietEvent(
        id: 'sankashti_chaturthi_${month}_$year',
        name: 'Sankashti Chaturthi',
        date: DateTime(year, month, 19), // Approximate 4th day after full moon
        category: EventCategory.festival,
        restriction: RestrictionType.vegOnly,
        description: 'Monthly Ganesha fasting day',
        reason: 'Sankashti Chaturthi - Lord Ganesha fasting day, vegetarian only',
      ));
    }

    return events;
  }

  static List<DietEvent> _getEclipses(int year) {
    // Sample eclipse dates - in production these would be calculated or fetched from astronomical APIs
    return [
      DietEvent(
        id: 'solar_eclipse_1_$year',
        name: 'Solar Eclipse',
        date: DateTime(year, 4, 8), // Sample date
        category: EventCategory.eclipse,
        restriction: RestrictionType.vegOnly,
        description: 'Solar eclipse - inauspicious for eating',
        reason: 'Solar Eclipse - Traditional restriction on food consumption during eclipse',
      ),
      DietEvent(
        id: 'lunar_eclipse_1_$year',
        name: 'Lunar Eclipse',
        date: DateTime(year, 10, 14), // Sample date
        category: EventCategory.eclipse,
        restriction: RestrictionType.vegOnly,
        description: 'Lunar eclipse - inauspicious for eating',
        reason: 'Lunar Eclipse - Traditional restriction on food consumption during eclipse',
      ),
    ];
  }

  // Helper method to get events for a specific category
  static List<DietEvent> getEventsByCategory(EventCategory category, int year) {
    return getDefaultEvents()
        .where((event) => event.category == category && event.date.year == year)
        .toList();
  }

  // Helper method to check if a date is a festival day
  static bool isFestivalDay(DateTime date) {
    final events = getDefaultEvents();
    return events.any((event) => 
        event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day &&
        event.category == EventCategory.festival);
  }

  // Helper method to get festivals in current month
  static List<DietEvent> getFestivalsInMonth(DateTime month) {
    return getDefaultEvents()
        .where((event) => 
            event.date.year == month.year &&
            event.date.month == month.month &&
            event.category == EventCategory.festival)
        .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  }
}