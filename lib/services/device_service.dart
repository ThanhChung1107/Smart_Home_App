// services/device_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:PBL4_smart_home/models/device.dart';
import 'auth_service.dart';

class DeviceService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<Map<String, dynamic>> getDevices() async {
    try {
      print('🔍 Getting devices from: $baseUrl/api/devices/');

      final headers = await AuthService.getHeaders();
      print('Headers with cookie: $headers');

      final response = await http.get(
        Uri.parse('$baseUrl/api/devices/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<Device> devices = [];
          for (var deviceData in data['devices']) {
            devices.add(Device.fromJson(deviceData));
          }
          print('✅ Loaded ${devices.length} devices');
          return {'success': true, 'devices': devices};
        } else {
          print('❌ API error: ${data['message']}');
          return {'success': false, 'message': data['message']};
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {'success': false, 'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Connection error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> controlDevice(
      String deviceId,
      String action, {
        Map<String, dynamic>? parameters,
      }) async {
    try {
      final headers = await AuthService.getHeaders();
      headers['Content-Type'] = 'application/json';

      final Map<String, dynamic> requestData = {
        'action': action,
        ...?parameters,
      };

      print('🚀 Controlling device: $deviceId, action: $action');

      final response = await http.post(
        Uri.parse('$baseUrl/api/devices/$deviceId/control/'),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(Duration(seconds: 10));

      print('📡 Control Response status: ${response.statusCode}');
      print('📦 Control Response body: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('❌ Control device error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
  // Thêm vào DeviceService
  static Future<Map<String, dynamic>> getDebugStats() async {
    try {
      final headers = await AuthService.getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/debug/stats/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('🐛 Debug Stats Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
  static Future<Map<String, dynamic>> cleanupSessions() async {
    try {
      final headers = await AuthService.getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/cleanup-sessions/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('🧹 Cleanup Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
  static Future<Map<String, dynamic>> getDeviceLogs(String deviceId) async {
    try {
      final headers = await AuthService.getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/devices/$deviceId/logs/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Logs Response status: ${response.statusCode}');
      print('📦 Logs Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<DeviceLog> logs = [];
          for (var logData in data['logs']) {
            logs.add(DeviceLog.fromJson(logData));
          }
          print('✅ Loaded ${logs.length} logs');
          return {'success': true, 'logs': logs};
        } else {
          return {'success': false, 'message': data['message']};
        }
      } else {
        return {'success': false, 'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // THÊM METHOD getRealStatistics
  static Future<Map<String, dynamic>> getRealStatistics(String period) async {
    try {
      final headers = await AuthService.getHeaders();

      print('📊 Getting statistics for period: $period');

      final response = await http.get(
        Uri.parse('$baseUrl/api/statistics/?period=$period'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Statistics Response status: ${response.statusCode}');
      print('📦 Statistics Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Statistics error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}