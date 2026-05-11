import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int colorIndex;
  final bool isAllDay;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.colorIndex = 0,
    this.isAllDay = false,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? colorIndex,
    bool? isAllDay,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorIndex: colorIndex ?? this.colorIndex,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'startHour': startTime?.hour,
      'startMinute': startTime?.minute,
      'endHour': endTime?.hour,
      'endMinute': endTime?.minute,
      'colorIndex': colorIndex,
      'isAllDay': isAllDay ? 1 : 0,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      startTime: map['startHour'] != null
          ? TimeOfDay(hour: map['startHour'], minute: map['startMinute'] ?? 0) : null,
      endTime: map['endHour'] != null
          ? TimeOfDay(hour: map['endHour'], minute: map['endMinute'] ?? 0) : null,
      colorIndex: map['colorIndex'] ?? 0,
      isAllDay: map['isAllDay'] == 1,
    );
  }

  static List<Color> get eventColors => [
    Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF8B5CF6),
    Color(0xFF06B6D4), Color(0xFFF97316),
  ];

  Color get color => eventColors[colorIndex % eventColors.length];

  String get timeRangeStr {
    if (isAllDay) return '全天';
    if (startTime == null) return '';
    final s = '${startTime!.hour.toString().padLeft(2,'0')}:${startTime!.minute.toString().padLeft(2,'0')}';
    if (endTime == null) return s;
    final e = '${endTime!.hour.toString().padLeft(2,'0')}:${endTime!.minute.toString().padLeft(2,'0')}';
    return '$s - $e';
  }
}
