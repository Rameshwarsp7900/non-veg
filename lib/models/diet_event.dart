import 'package:intl/intl.dart';

enum RestrictionType {
  nonVegAllowed,
  vegOnly,
  conditional,
}

enum EventCategory {
  festival,
  eclipse,
  holiday,
  personal,
  weekly,
  family,
}

class DietEvent {
  final String id;
  final String name;
  final DateTime date;
  final EventCategory category;
  final RestrictionType restriction;
  final String? description;
  final String? reason;
  final bool isRecurring;
  final String? createdBy; // For family rules - tracks who created it

  DietEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    required this.restriction,
    this.description,
    this.reason,
    this.isRecurring = false,
    this.createdBy,
  });

  // Create a copy with updated fields
  DietEvent copyWith({
    String? id,
    String? name,
    DateTime? date,
    EventCategory? category,
    RestrictionType? restriction,
    String? description,
    String? reason,
    bool? isRecurring,
    String? createdBy,
  }) {
    return DietEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      category: category ?? this.category,
      restriction: restriction ?? this.restriction,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      isRecurring: isRecurring ?? this.isRecurring,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'category': category.toString(),
      'restriction': restriction.toString(),
      'description': description,
      'reason': reason,
      'isRecurring': isRecurring,
      'createdBy': createdBy,
    };
  }

  factory DietEvent.fromJson(Map<String, dynamic> json) {
    return DietEvent(
      id: json['id'],
      name: json['name'],
      date: DateFormat('yyyy-MM-dd').parse(json['date']),
      category: EventCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      restriction: RestrictionType.values.firstWhere(
        (e) => e.toString() == json['restriction'],
      ),
      description: json['description'],
      reason: json['reason'],
      isRecurring: json['isRecurring'] ?? false,
      createdBy: json['createdBy'],
    );
  }

  // Helper to get icon for the event
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

  // Helper to get color for the event
  String get colorCode {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return 'red';
      case RestrictionType.nonVegAllowed:
        return 'green';
      case RestrictionType.conditional:
        return 'yellow';
    }
  }
}