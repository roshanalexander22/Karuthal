class ReminderModel {
  final String id;
  final String title;
  final String? description;
  final String dosage;
  final String instructionsMl;
  final String reminderType;
  final DateTime scheduledTime;
  final String? recurrenceRule;
  final bool isActive;
  final DateTime? lastAcknowledgedAt;

  const ReminderModel({
    required this.id,
    required this.title,
    this.description,
    this.dosage = '1 ഗുളിക (1 Tablet)',
    this.instructionsMl = 'ഭക്ഷണത്തിന് ശേഷം (After food)',
    this.reminderType = 'MEDICINE',
    required this.scheduledTime,
    this.recurrenceRule = 'DAILY',
    this.isActive = true,
    this.lastAcknowledgedAt,
  });

  bool get isTakenToday {
    if (lastAcknowledgedAt == null) return false;
    final now = DateTime.now();
    return lastAcknowledgedAt!.year == now.year &&
        lastAcknowledgedAt!.month == now.month &&
        lastAcknowledgedAt!.day == now.day;
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dosage: json['dosage'] as String? ?? '1 ഗുളിക',
      instructionsMl: json['instructions_ml'] as String? ?? 'ഭക്ഷണത്തിന് ശേഷം',
      reminderType: json['reminder_type'] as String? ?? 'MEDICINE',
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.tryParse(json['scheduled_time'] as String) ?? DateTime.now()
          : DateTime.now(),
      recurrenceRule: json['recurrence_rule'] as String? ?? 'DAILY',
      isActive: json['is_active'] as bool? ?? true,
      lastAcknowledgedAt: json['last_acknowledged_at'] != null
          ? DateTime.tryParse(json['last_acknowledged_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'dosage': dosage,
      'instructions_ml': instructionsMl,
      'reminder_type': reminderType,
      'scheduled_time': scheduledTime.toIso8601String(),
      'recurrence_rule': recurrenceRule,
      'is_active': isActive,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    String? dosage,
    String? instructionsMl,
    String? reminderType,
    DateTime? scheduledTime,
    String? recurrenceRule,
    bool? isActive,
    DateTime? lastAcknowledgedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
      instructionsMl: instructionsMl ?? this.instructionsMl,
      reminderType: reminderType ?? this.reminderType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      isActive: isActive ?? this.isActive,
      lastAcknowledgedAt: lastAcknowledgedAt ?? this.lastAcknowledgedAt,
    );
  }
}
