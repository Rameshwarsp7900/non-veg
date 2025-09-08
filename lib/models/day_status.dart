import 'diet_event.dart';

class DayStatus {
  final DateTime date;
  final RestrictionType restriction;
  final String reason;
  final List<DietEvent> events;
  final String? userNotes;
  final bool hasUserOverride;

  DayStatus({
    required this.date,
    required this.restriction,
    required this.reason,
    this.events = const [],
    this.userNotes,
    this.hasUserOverride = false,
  });

  DayStatus copyWith({
    DateTime? date,
    RestrictionType? restriction,
    String? reason,
    List<DietEvent>? events,
    String? userNotes,
    bool? hasUserOverride,
  }) {
    return DayStatus(
      date: date ?? this.date,
      restriction: restriction ?? this.restriction,
      reason: reason ?? this.reason,
      events: events ?? this.events,
      userNotes: userNotes ?? this.userNotes,
      hasUserOverride: hasUserOverride ?? this.hasUserOverride,
    );
  }

  // Helper methods for UI display
  String get iconText {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return '❌';
      case RestrictionType.nonVegAllowed:
        return '✅';
      case RestrictionType.conditional:
        return '⚠️';
    }
  }

  String get statusText {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return 'Veg Only';
      case RestrictionType.nonVegAllowed:
        return 'Non-Veg OK';
      case RestrictionType.conditional:
        return 'Conditional';
    }
  }

  String get shortReason {
    if (reason.length > 30) {
      return '${reason.substring(0, 27)}...';
    }
    return reason;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'restriction': restriction.toString(),
      'reason': reason,
      'events': events.map((e) => e.toJson()).toList(),
      'userNotes': userNotes,
      'hasUserOverride': hasUserOverride,
    };
  }

  factory DayStatus.fromJson(Map<String, dynamic> json) {
    return DayStatus(
      date: DateTime.parse(json['date']),
      restriction: RestrictionType.values.firstWhere(
        (e) => e.toString() == json['restriction'],
      ),
      reason: json['reason'],
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => DietEvent.fromJson(e))
          .toList() ?? [],
      userNotes: json['userNotes'],
      hasUserOverride: json['hasUserOverride'] ?? false,
    );
  }
}

class ManualOverride {
  final String id;
  final DateTime date;
  final RestrictionType restriction;
  final String reason;
  final String? notes;
  final DateTime createdAt;

  ManualOverride({
    required this.id,
    required this.date,
    required this.restriction,
    required this.reason,
    this.notes,
    required this.createdAt,
  });

  ManualOverride copyWith({
    String? id,
    DateTime? date,
    RestrictionType? restriction,
    String? reason,
    String? notes,
    DateTime? createdAt,
  }) {
    return ManualOverride(
      id: id ?? this.id,
      date: date ?? this.date,
      restriction: restriction ?? this.restriction,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'restriction': restriction.toString(),
      'reason': reason,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ManualOverride.fromJson(Map<String, dynamic> json) {
    return ManualOverride(
      id: json['id'],
      date: DateTime.parse(json['date']),
      restriction: RestrictionType.values.firstWhere(
        (e) => e.toString() == json['restriction'],
      ),
      reason: json['reason'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}