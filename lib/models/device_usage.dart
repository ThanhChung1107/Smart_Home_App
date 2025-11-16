// models/device_usage.dart
class DeviceUsage {
  final String deviceName;
  final String deviceType;
  final int turnOnCount;
  final double totalUsageHours;
  final double powerConsumption;
  final double cost;
  final List<Map<String, dynamic>> usageData;

  DeviceUsage({
    required this.deviceName,
    required this.deviceType,
    required this.turnOnCount,
    required this.totalUsageHours,
    required this.powerConsumption,
    required this.cost,
    required this.usageData,
  });

  // Factory method để parse từ JSON
  factory DeviceUsage.fromJson(Map<String, dynamic> json) {
    return DeviceUsage(
      deviceName: json['device_name'] ?? 'Unknown Device',
      deviceType: json['device_type'] ?? 'device',
      turnOnCount: json['turn_on_count'] ?? 0,
      totalUsageHours: (json['total_usage_hours'] ?? 0).toDouble(),
      powerConsumption: (json['power_consumption'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
      usageData: List<Map<String, dynamic>>.from(json['usage_data'] ?? []),
    );
  }
}