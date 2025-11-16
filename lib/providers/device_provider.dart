import 'package:flutter/foundation.dart';
import '../models/device.dart';
import 'package:PBL4_smart_home/services/device_service.dart';

class DeviceProvider with ChangeNotifier {
  List<Device> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔄 Loading devices...');
    final result = await DeviceService.getDevices();

    if (result['success'] == true) {
      _devices = result['devices'];
      print('✅ Devices loaded: ${_devices.length}');
    } else {
      _error = result['message'];
      print('❌ Error loading devices: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }

  // SỬA 1: Đổi return type thành Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> toggleDevice(String deviceId) async {
    try {
      final result = await DeviceService.controlDevice(deviceId, 'toggle');

      if (result['success'] == true) {
        // Cập nhật trạng thái device trong list
        final index = _devices.indexWhere((device) => device.id == deviceId);
        if (index != -1) {
          // Kiểm tra dữ liệu trước khi tạo Device mới
          if (result['device'] != null) {
            _devices[index] = Device.fromJson(result['device']);
            notifyListeners();
          }
        }
      } else {
        print('Toggle device error: ${result['message']}');
      }

      return result; // Trả về kết quả
    } catch (e) {
      print('Toggle device exception: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // SỬA 2: Các method control khác cũng đổi return type
  Future<Map<String, dynamic>> turnOnDevice(String deviceId) async {
    try {
      final result = await DeviceService.controlDevice(deviceId, 'on');

      if (result['success'] == true) {
        final index = _devices.indexWhere((device) => device.id == deviceId);
        if (index != -1) {
          _devices[index] = Device.fromJson(result['device']);
          notifyListeners();
        }
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  Future<Map<String, dynamic>> turnOffDevice(String deviceId) async {
    try {
      final result = await DeviceService.controlDevice(deviceId, 'off');

      if (result['success'] == true) {
        final index = _devices.indexWhere((device) => device.id == deviceId);
        if (index != -1) {
          _devices[index] = Device.fromJson(result['device']);
          notifyListeners();
        }
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  List<Device> getDevicesByRoom(String room) {
    return _devices.where((device) => device.room == room).toList();
  }

  List<Device> getDevicesByType(String type) {
    return _devices.where((device) => device.deviceType == type).toList();
  }
}