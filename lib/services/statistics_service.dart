import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:PBL4_smart_home/models/statistics_model.dart';
import 'auth_service.dart'; // Thêm import

class StatisticsService {
  final String baseUrl;

  StatisticsService({required this.baseUrl});

  // Lấy thống kê thực tế (RealStatisticsView)
  Future<Map<String, dynamic>> getRealStatistics(String period) async {
    try {
      final headers = await AuthService.getHeaders(); // Thêm authentication

      final response = await http.get(
        Uri.parse('$baseUrl/api/statistics/?period=$period'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Real Stats Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Real stats error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Lấy thống kê theo thiết bị (DeviceStatisticsView)
  Future<DeviceStatisticsSummary> getDeviceStatistics(String deviceId, String period) async {
    try {
      final headers = await AuthService.getHeaders(); // Thêm authentication

      final response = await http.get(
        Uri.parse('$baseUrl/api/devices/$deviceId/statistics/?period=$period'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Device Stats Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return DeviceStatisticsSummary.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'API returned success: false');
        }
      }
      throw Exception('Failed to load device statistics: ${response.statusCode}');
    } catch (e) {
      print('❌ Lỗi lấy thống kê thiết bị: $e');
      rethrow;
    }
  }

  // Lấy thống kê tổng quan (OverallStatisticsView)
  Future<OverallStatistics> getOverallStatistics(String period) async {
    try {
      final headers = await AuthService.getHeaders(); // Thêm authentication

      final response = await http.get(
        Uri.parse('$baseUrl/api/statistics/overall/?period=$period'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Overall Stats Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return OverallStatistics.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'API returned success: false');
        }
      }
      throw Exception('Failed to load overall statistics: ${response.statusCode}');
    } catch (e) {
      print('❌ Lỗi lấy thống kê tổng quan: $e');
      rethrow;
    }
  }

  // Lấy thống kê real-time (RealTimeUsageView)
  Future<Map<String, dynamic>> getRealTimeUsage() async {
    try {
      final headers = await AuthService.getHeaders(); // Thêm authentication

      final response = await http.get(
        Uri.parse('$baseUrl/api/statistics/realtime/'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('📡 Real-time Stats Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Lỗi server: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Lỗi lấy thống kê real-time: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}