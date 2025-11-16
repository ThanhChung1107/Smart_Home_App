class Schedule {
  String id;
  String deviceId;
  String deviceName;
  String deviceType;
  String action;
  String scheduledTime;
  String? scheduledDate;
  String repeatType;
  List<String> repeatDays;
  bool isActive;
  bool isExecuted;
  String? nextExecution;
  String createdAt;

  Schedule({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.action,
    required this.scheduledTime,
    this.scheduledDate,
    required this.repeatType,
    required this.repeatDays,
    required this.isActive,
    required this.isExecuted,
    this.nextExecution,
    required this.createdAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      deviceId: json['device_id'] ?? '',
      deviceName: json['device_name'] ?? '',
      deviceType: json['device_type'] ?? '',
      action: json['action'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      scheduledDate: json['scheduled_date'],
      repeatType: json['repeat_type'] ?? 'once',
      repeatDays: List<String>.from(json['repeat_days'] ?? []),
      isActive: json['is_active'] ?? true,
      isExecuted: json['is_executed'] ?? false,
      nextExecution: json['next_execution'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'action': action,
      'scheduled_time': scheduledTime,
      'scheduled_date': scheduledDate,
      'repeat_type': repeatType,
      'repeat_days': repeatDays,
    };
  }

  String get displayAction => action == 'on' ? 'BẬT' : 'TẮT';

  String get repeatText {
    switch (repeatType) {
      case 'once':
        return 'Một lần';
      case 'daily':
        return 'Hàng ngày';
      case 'weekly':
        if (repeatDays.isEmpty) return 'Hàng tuần';
        final dayNames = repeatDays.map((day) => _getDayName(day)).toList();
        return 'Hàng tuần: ${dayNames.join(', ')}';
      default:
        return repeatType;
    }
  }

  String _getDayName(String day) {
    switch (day) {
      case 'mon': return 'T2';
      case 'tue': return 'T3';
      case 'wed': return 'T4';
      case 'thu': return 'T5';
      case 'fri': return 'T6';
      case 'sat': return 'T7';
      case 'sun': return 'CN';
      default: return day;
    }
  }

  String get formattedTime {
    try {
      final timeParts = scheduledTime.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = timeParts[1];
        return '${hour.toString().padLeft(2, '0')}:$minute';
      }
      return scheduledTime;
    } catch (e) {
      return scheduledTime;
    }
  }
}