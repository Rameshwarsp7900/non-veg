import 'diet_event.dart';

class WeeklyRule {
  final int weekday; // 1 = Monday, 7 = Sunday
  final RestrictionType restriction;
  final String reason;
  final bool isActive;

  WeeklyRule({
    required this.weekday,
    required this.restriction,
    required this.reason,
    this.isActive = true,
  });

  WeeklyRule copyWith({
    int? weekday,
    RestrictionType? restriction,
    String? reason,
    bool? isActive,
  }) {
    return WeeklyRule(
      weekday: weekday ?? this.weekday,
      restriction: restriction ?? this.restriction,
      reason: reason ?? this.reason,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'restriction': restriction.toString(),
      'reason': reason,
      'isActive': isActive,
    };
  }

  factory WeeklyRule.fromJson(Map<String, dynamic> json) {
    return WeeklyRule(
      weekday: json['weekday'],
      restriction: RestrictionType.values.firstWhere(
        (e) => e.toString() == json['restriction'],
      ),
      reason: json['reason'],
      isActive: json['isActive'] ?? true,
    );
  }

  String get weekdayName {
    const weekdays = [
      'Monday',
      'Tuesday', 
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[weekday - 1];
  }
}

class UserPreferences {
  final String userId;
  final String userName;
  final DateTime? birthDate;
  final List<WeeklyRule> weeklyRules;
  final bool enableNotifications;
  final TimeOfDay? morningReminderTime;
  final TimeOfDay? eveningReminderTime;
  final String familyGroupId;
  final bool isFamilyAdmin; // For Mom's rules functionality

  UserPreferences({
    required this.userId,
    required this.userName,
    this.birthDate,
    this.weeklyRules = const [],
    this.enableNotifications = true,
    this.morningReminderTime,
    this.eveningReminderTime,
    this.familyGroupId = '',
    this.isFamilyAdmin = false,
  });

  UserPreferences copyWith({
    String? userId,
    String? userName,
    DateTime? birthDate,
    List<WeeklyRule>? weeklyRules,
    bool? enableNotifications,
    TimeOfDay? morningReminderTime,
    TimeOfDay? eveningReminderTime,
    String? familyGroupId,
    bool? isFamilyAdmin,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      birthDate: birthDate ?? this.birthDate,
      weeklyRules: weeklyRules ?? this.weeklyRules,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      familyGroupId: familyGroupId ?? this.familyGroupId,
      isFamilyAdmin: isFamilyAdmin ?? this.isFamilyAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'birthDate': birthDate?.toIso8601String(),
      'weeklyRules': weeklyRules.map((rule) => rule.toJson()).toList(),
      'enableNotifications': enableNotifications,
      'morningReminderTime': morningReminderTime != null 
          ? '${morningReminderTime!.hour}:${morningReminderTime!.minute}' 
          : null,
      'eveningReminderTime': eveningReminderTime != null 
          ? '${eveningReminderTime!.hour}:${eveningReminderTime!.minute}' 
          : null,
      'familyGroupId': familyGroupId,
      'isFamilyAdmin': isFamilyAdmin,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'],
      userName: json['userName'],
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate']) 
          : null,
      weeklyRules: (json['weeklyRules'] as List<dynamic>?)
          ?.map((rule) => WeeklyRule.fromJson(rule))
          .toList() ?? [],
      enableNotifications: json['enableNotifications'] ?? true,
      morningReminderTime: json['morningReminderTime'] != null
          ? _parseTimeOfDay(json['morningReminderTime'])
          : null,
      eveningReminderTime: json['eveningReminderTime'] != null
          ? _parseTimeOfDay(json['eveningReminderTime'])
          : null,
      familyGroupId: json['familyGroupId'] ?? '',
      isFamilyAdmin: json['isFamilyAdmin'] ?? false,
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

// For TimeOfDay import
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}