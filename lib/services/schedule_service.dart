import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ScheduleService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<Map<String, dynamic>> getSchedules() async {
    try {
      print('🔍 Getting schedules from: $baseUrl/api/schedules/');

      final headers = await AuthService.getHeaders();
      print('Headers with cookie: $headers');

      final response = await http.get(
        Uri.parse('$baseUrl/api/schedules/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Schedules Response status: ${response.statusCode}');
      print('📦 Schedules Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Loaded ${data['schedules']?.length ?? 0} schedules');
          return {'success': true, 'schedules': data['schedules']};
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

  static Future<Map<String, dynamic>> createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final headers = await AuthService.getHeaders();
      headers['Content-Type'] = 'application/json';

      print('🚀 Creating schedule: $scheduleData');

      final response = await http.post(
        Uri.parse('$baseUrl/api/schedules/'),
        headers: headers,
        body: json.encode(scheduleData),
      ).timeout(Duration(seconds: 10));

      print('📡 Create Schedule Response status: ${response.statusCode}');
      print('📦 Create Schedule Response body: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('❌ Create schedule error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSchedule(String scheduleId, bool isActive) async {
    try {
      final headers = await AuthService.getHeaders();
      headers['Content-Type'] = 'application/json';

      print('🔄 Updating schedule: $scheduleId, active: $isActive');

      final response = await http.put(
        Uri.parse('$baseUrl/api/schedules/$scheduleId/'),
        headers: headers,
        body: json.encode({'is_active': isActive}),
      ).timeout(Duration(seconds: 10));

      print('📡 Update Schedule Response status: ${response.statusCode}');
      print('📦 Update Schedule Response body: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('❌ Update schedule error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteSchedule(String scheduleId) async {
    try {
      final headers = await AuthService.getHeaders();

      print('🗑️ Deleting schedule: $scheduleId');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/schedules/$scheduleId/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Delete Schedule Response status: ${response.statusCode}');
      print('📦 Delete Schedule Response body: ${response.body}');

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('❌ Delete schedule error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}