import 'dart:convert';

class Device {
  final String id;
  final String name;
  final String deviceType;
  final String room;
  final bool isOn;
  final Map<String, dynamic> status;
  final String? ipAddress;
  final DateTime createdAt;

  Device({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.room,
    required this.isOn,
    required this.status,
    this.ipAddress,
    required this.createdAt,
  });

  // THÊM METHOD copyWith VÀO ĐÂY
  Device copyWith({
    String? id,
    String? name,
    String? deviceType,
    String? room,
    bool? isOn,
    Map<String, dynamic>? status,
    String? ipAddress,
    DateTime? createdAt,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Các method khác giữ nguyên...
  factory Device.fromJson(Map<String, dynamic> json) {
    print('📋 Device JSON: $json'); // Debug

    return Device(
      id: _parseString(json['id']),
      name: _parseString(json['name']),
      deviceType: _parseString(json['device_type']),
      room: _parseString(json['room']),
      isOn: json['is_on'] ?? false,
      status: _parseStatus(json['status']),
      ipAddress: _parseString(json['ip_address']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  // Các helper methods và getters khác giữ nguyên...
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static Map<String, dynamic> _parseStatus(dynamic status) {
    if (status == null) return {};
    if (status is Map<String, dynamic>) return status;
    if (status is String) {
      try {
        return json.decode(status);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  String get icon {
    switch (deviceType) {
      case 'light':
        return '💡';
      case 'fan':
        return '🌀';
      case 'ac':
        return '❄️';
      case 'socket':
        return '🔌';
      case 'door':
        return '🚪';
      default:
        return '⚙️';
    }
  }

  String get typeName {
    switch (deviceType) {
      case 'light':
        return 'Đèn';
      case 'fan':
        return 'Quạt';
      case 'ac':
        return 'Điều hòa';
      case 'socket':
        return 'Ổ cắm';
      case 'door':
        return 'Cửa';
      default:
        return 'Thiết bị';
    }
  }

  String get roomName {
    switch (room) {
      case 'living_room':
        return 'Phòng khách';
      case 'bedroom':
        return 'Phòng ngủ';
      case 'kitchen':
        return 'Nhà bếp';
      case 'bathroom':
        return 'Phòng tắm';
      case 'outside':
        return 'Bên ngoài';
      default:
        return room;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'device_type': deviceType,
      'room': room,
      'is_on': isOn,
      'status': status,
      'ip_address': ipAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }
}