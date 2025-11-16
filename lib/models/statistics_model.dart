class DeviceStatisticsSummary {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final int totalTurnOn;
  final double totalUsageHours;
  final double totalPowerConsumption;
  final int totalCost;
  final double avgDailyUsageHours;
  final int avgDailyCost;
  final List<DailyStat> dailyData;
  final List<UsageSession> recentSessions;
  final double powerRate;
  final int electricityPrice;

  DeviceStatisticsSummary({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.totalTurnOn,
    required this.totalUsageHours,
    required this.totalPowerConsumption,
    required this.totalCost,
    required this.avgDailyUsageHours,
    required this.avgDailyCost,
    required this.dailyData,
    required this.recentSessions,
    required this.powerRate,
    required this.electricityPrice,
  });

  factory DeviceStatisticsSummary.fromJson(Map<String, dynamic> json) {
    return DeviceStatisticsSummary(
      deviceId: json['device']['id'],
      deviceName: json['device']['name'],
      deviceType: json['device']['type'],
      totalTurnOn: json['summary']['total_turn_on'],
      totalUsageHours: json['summary']['total_usage_hours'],
      totalPowerConsumption: json['summary']['total_power_consumption'],
      totalCost: json['summary']['total_cost'],
      avgDailyUsageHours: json['summary']['avg_daily_usage_hours'],
      avgDailyCost: json['summary']['avg_daily_cost'],
      dailyData: (json['daily_data'] as List).map((e) => DailyStat.fromJson(e)).toList(),
      recentSessions: (json['recent_sessions'] as List).map((e) => UsageSession.fromJson(e)).toList(),
      powerRate: json['power_rate'],
      electricityPrice: json['electricity_price'],
    );
  }
}

class DailyStat {
  final String date;
  final double usageHours;
  final int cost;
  final int turnOnCount;

  DailyStat({
    required this.date,
    required this.usageHours,
    required this.cost,
    required this.turnOnCount,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: json['date'],
      usageHours: json['usage_hours'],
      cost: json['cost'],
      turnOnCount: json['turn_on_count'],
    );
  }
}

class UsageSession {
  final String startTime;
  final String? endTime;
  final int durationMinutes;
  final double durationHours;

  UsageSession({
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.durationHours,
  });

  factory UsageSession.fromJson(Map<String, dynamic> json) {
    return UsageSession(
      startTime: json['start_time'],
      endTime: json['end_time'],
      durationMinutes: json['duration_minutes'],
      durationHours: json['duration_hours'],
    );
  }
}

class OverallStatistics {
  final int totalDevices;
  final int totalTurnOn;
  final double totalUsageHours;
  final double totalPowerConsumption;
  final int totalCost;
  final int avgDailyCost;
  final List<DeviceTypeStat> byDeviceType;
  final List<RoomStat> byRoom;
  final List<TopDevice> topUsageDevices;

  OverallStatistics({
    required this.totalDevices,
    required this.totalTurnOn,
    required this.totalUsageHours,
    required this.totalPowerConsumption,
    required this.totalCost,
    required this.avgDailyCost,
    required this.byDeviceType,
    required this.byRoom,
    required this.topUsageDevices,
  });

  factory OverallStatistics.fromJson(Map<String, dynamic> json) {
    return OverallStatistics(
      totalDevices: json['overall_summary']['total_devices'],
      totalTurnOn: json['overall_summary']['total_turn_on'],
      totalUsageHours: json['overall_summary']['total_usage_hours'],
      totalPowerConsumption: json['overall_summary']['total_power_consumption'],
      totalCost: json['overall_summary']['total_cost'],
      avgDailyCost: json['overall_summary']['avg_daily_cost'],
      byDeviceType: (json['by_device_type'] as List).map((e) => DeviceTypeStat.fromJson(e)).toList(),
      byRoom: (json['by_room'] as List).map((e) => RoomStat.fromJson(e)).toList(),
      topUsageDevices: (json['top_usage_devices'] as List).map((e) => TopDevice.fromJson(e)).toList(),
    );
  }
}

class DeviceTypeStat {
  final String type;
  final String typeName;
  final double totalUsageHours;
  final int totalCost;
  final int totalTurnOn;
  final int deviceCount;

  DeviceTypeStat({
    required this.type,
    required this.typeName,
    required this.totalUsageHours,
    required this.totalCost,
    required this.totalTurnOn,
    required this.deviceCount,
  });

  factory DeviceTypeStat.fromJson(Map<String, dynamic> json) {
    return DeviceTypeStat(
      type: json['type'],
      typeName: json['type_name'],
      totalUsageHours: json['total_usage_hours'],
      totalCost: json['total_cost'],
      totalTurnOn: json['total_turn_on'],
      deviceCount: json['device_count'],
    );
  }
}

class RoomStat {
  final String room;
  final String roomName;
  final double totalUsageHours;
  final int totalCost;
  final int deviceCount;

  RoomStat({
    required this.room,
    required this.roomName,
    required this.totalUsageHours,
    required this.totalCost,
    required this.deviceCount,
  });

  factory RoomStat.fromJson(Map<String, dynamic> json) {
    return RoomStat(
      room: json['room'],
      roomName: json['room_name'],
      totalUsageHours: json['total_usage_hours'],
      totalCost: json['total_cost'],
      deviceCount: json['device_count'],
    );
  }
}

class TopDevice {
  final String id;
  final String name;
  final String type;
  final double usageHours;
  final int cost;

  TopDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.usageHours,
    required this.cost,
  });

  factory TopDevice.fromJson(Map<String, dynamic> json) {
    return TopDevice(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      usageHours: json['usage_hours'],
      cost: json['cost'],
    );
  }
}