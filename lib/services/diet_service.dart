import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/diet_event.dart';
import '../models/user_preferences.dart';
import '../models/day_status.dart';
import '../utils/default_events.dart';

class DietService extends ChangeNotifier {
  List<DietEvent> _events = [];
  List<ManualOverride> _manualOverrides = [];
  UserPreferences? _userPreferences;
  Map<String, DayStatus> _dayStatusCache = {};

  List<DietEvent> get events => List.unmodifiable(_events);
  List<ManualOverride> get manualOverrides => List.unmodifiable(_manualOverrides);
  UserPreferences? get userPreferences => _userPreferences;

  DietService() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    await loadData();
    if (_events.isEmpty) {
      await _loadDefaultEvents();
    }
  }

  // Load default Hindu festivals and events
  Future<void> _loadDefaultEvents() async {
    _events.addAll(DefaultEvents.getDefaultEvents());
    await saveData();
    notifyListeners();
  }

  // Load data from local storage
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load events
    final eventsJson = prefs.getString('diet_events');
    if (eventsJson != null) {
      final eventsList = json.decode(eventsJson) as List;
      _events = eventsList.map((e) => DietEvent.fromJson(e)).toList();
    }

    // Load manual overrides
    final overridesJson = prefs.getString('manual_overrides');
    if (overridesJson != null) {
      final overridesList = json.decode(overridesJson) as List;
      _manualOverrides = overridesList.map((e) => ManualOverride.fromJson(e)).toList();
    }

    // Load user preferences
    final prefsJson = prefs.getString('user_preferences');
    if (prefsJson != null) {
      _userPreferences = UserPreferences.fromJson(json.decode(prefsJson));
    } else {
      // Create default user preferences
      _userPreferences = UserPreferences(
        userId: 'default_user',
        userName: 'User',
        weeklyRules: _getDefaultWeeklyRules(),
      );
      await saveData();
    }

    notifyListeners();
  }

  // Save data to local storage
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save events
    final eventsJson = json.encode(_events.map((e) => e.toJson()).toList());
    await prefs.setString('diet_events', eventsJson);

    // Save manual overrides
    final overridesJson = json.encode(_manualOverrides.map((e) => e.toJson()).toList());
    await prefs.setString('manual_overrides', overridesJson);

    // Save user preferences
    if (_userPreferences != null) {
      final prefsJson = json.encode(_userPreferences!.toJson());
      await prefs.setString('user_preferences', prefsJson);
    }
  }

  // Get default weekly rules (Tuesday and Saturday veg-only)
  List<WeeklyRule> _getDefaultWeeklyRules() {
    return [
      WeeklyRule(
        weekday: 2, // Tuesday
        restriction: RestrictionType.vegOnly,
        reason: "Tuesday - Hanuman's day (traditional restriction)",
      ),
      WeeklyRule(
        weekday: 6, // Saturday
        restriction: RestrictionType.vegOnly,
        reason: "Saturday - Hanuman's day (traditional restriction)",
      ),
    ];
  }

  // Calculate day status for a given date
  DayStatus getDayStatus(DateTime date) {
    final dateKey = _getDateKey(date);
    
    // Check cache first
    if (_dayStatusCache.containsKey(dateKey)) {
      return _dayStatusCache[dateKey]!;
    }

    // Calculate status
    final status = _calculateDayStatus(date);
    _dayStatusCache[dateKey] = status;
    return status;
  }

  DayStatus _calculateDayStatus(DateTime date) {
    // Priority order:
    // 1. Manual overrides (highest priority)
    // 2. Special events (festivals, eclipses, etc.)
    // 3. Weekly rules
    // 4. Default (non-veg allowed)

    final dateKey = _getDateKey(date);
    
    // Check manual overrides first
    final override = _manualOverrides.where((o) => _getDateKey(o.date) == dateKey).firstOrNull;
    if (override != null) {
      return DayStatus(
        date: date,
        restriction: override.restriction,
        reason: override.reason,
        userNotes: override.notes,
        hasUserOverride: true,
      );
    }

    // Check special events
    final dayEvents = _events.where((e) => _getDateKey(e.date) == dateKey).toList();
    if (dayEvents.isNotEmpty) {
      // Find the most restrictive event
      final vegOnlyEvents = dayEvents.where((e) => e.restriction == RestrictionType.vegOnly);
      if (vegOnlyEvents.isNotEmpty) {
        final event = vegOnlyEvents.first;
        return DayStatus(
          date: date,
          restriction: RestrictionType.vegOnly,
          reason: event.reason ?? '${event.name} - ${event.category.name}',
          events: dayEvents,
        );
      }

      final conditionalEvents = dayEvents.where((e) => e.restriction == RestrictionType.conditional);
      if (conditionalEvents.isNotEmpty) {
        final event = conditionalEvents.first;
        return DayStatus(
          date: date,
          restriction: RestrictionType.conditional,
          reason: event.reason ?? '${event.name} - ${event.category.name}',
          events: dayEvents,
        );
      }
    }

    // Check weekly rules
    if (_userPreferences != null) {
      final weekday = date.weekday;
      final weeklyRule = _userPreferences!.weeklyRules
          .where((rule) => rule.weekday == weekday && rule.isActive)
          .firstOrNull;
      
      if (weeklyRule != null) {
        return DayStatus(
          date: date,
          restriction: weeklyRule.restriction,
          reason: weeklyRule.reason,
          events: dayEvents,
        );
      }
    }

    // Default: non-veg allowed
    return DayStatus(
      date: date,
      restriction: RestrictionType.nonVegAllowed,
      reason: 'No restrictions apply',
      events: dayEvents,
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Event management methods
  Future<void> addEvent(DietEvent event) async {
    _events.add(event);
    _clearCache();
    await saveData();
    notifyListeners();
  }

  Future<void> updateEvent(DietEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      _clearCache();
      await saveData();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    _clearCache();
    await saveData();
    notifyListeners();
  }

  // Manual override methods
  Future<void> addManualOverride(ManualOverride override) async {
    // Remove existing override for the same date
    _manualOverrides.removeWhere((o) => _getDateKey(o.date) == _getDateKey(override.date));
    _manualOverrides.add(override);
    _clearCache();
    await saveData();
    notifyListeners();
  }

  Future<void> removeManualOverride(String overrideId) async {
    _manualOverrides.removeWhere((o) => o.id == overrideId);
    _clearCache();
    await saveData();
    notifyListeners();
  }

  // User preferences methods
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    _userPreferences = preferences;
    _clearCache();
    await saveData();
    notifyListeners();
  }

  // Cache management
  void _clearCache() {
    _dayStatusCache.clear();
  }

  // Get events for a specific month
  List<DietEvent> getEventsForMonth(DateTime month) {
    return _events.where((event) {
      return event.date.year == month.year && event.date.month == month.month;
    }).toList();
  }

  // Get upcoming events (next 7 days)
  List<DietEvent> getUpcomingEvents() {
    final now = DateTime.now();
    final weekFromNow = now.add(Duration(days: 7));
    
    return _events.where((event) {
      return event.date.isAfter(now) && event.date.isBefore(weekFromNow);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // Check if a specific food is allowed today
  bool isFoodAllowedToday(String foodType) {
    final today = DateTime.now();
    final status = getDayStatus(today);
    
    switch (status.restriction) {
      case RestrictionType.nonVegAllowed:
        return true;
      case RestrictionType.vegOnly:
        return foodType.toLowerCase().contains('veg') && !foodType.toLowerCase().contains('non');
      case RestrictionType.conditional:
        // For conditional, we assume only certain non-veg might be allowed
        // This can be customized based on specific rules
        return foodType.toLowerCase().contains('veg');
    }
  }

  // Generate explanation for today's dietary status
  String getTodayExplanation() {
    final today = DateTime.now();
    final status = getDayStatus(today);
    
    String explanation = 'Today is ${status.statusText}.';
    
    if (status.reason.isNotEmpty) {
      explanation += ' ${status.reason}';
    }
    
    if (status.events.isNotEmpty) {
      final eventNames = status.events.map((e) => e.name).join(', ');
      explanation += ' Special events today: $eventNames.';
    }
    
    if (status.userNotes != null && status.userNotes!.isNotEmpty) {
      explanation += ' Note: ${status.userNotes}';
    }
    
    return explanation;
  }
}

// Extension to handle nullable firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}