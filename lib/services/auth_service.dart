import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.2.149:8000';
  static String? sessionCookie;

  // Method kiểm tra đăng nhập
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Method đăng ký - SỬA LẠI PHẦN NÀY
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String role,
    String? avatarBase64,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
        'role': role,
      };

      if (avatarBase64 != null) {
        requestData['avatar'] = avatarBase64;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Method đăng nhập
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('Login Response Headers: ${response.headers}');
      print('Login Response Body: ${response.body}');

      // Lấy session cookie từ headers
      _saveSessionCookie(response);

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(data['user']));
        await prefs.setBool('isLoggedIn', true);

        // Lưu session cookie
        if (sessionCookie != null) {
          await prefs.setString('session_cookie', sessionCookie!);
        }
      }

      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Hàm lưu session cookie
  static void _saveSessionCookie(http.Response response) {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      final regex = RegExp(r'sessionid=([^;]+)');
      final match = regex.firstMatch(setCookieHeader);
      if (match != null) {
        sessionCookie = match.group(0);
        print('Saved session cookie: $sessionCookie');
      }
    }
  }

  // Hàm lấy session cookie đã lưu
  static Future<String?> getSessionCookie() async {
    if (sessionCookie != null) return sessionCookie;

    final prefs = await SharedPreferences.getInstance();
    sessionCookie = prefs.getString('session_cookie');
    return sessionCookie;
  }

  // Thêm session cookie vào headers
  static Future<Map<String, String>> getHeaders() async {
    final cookie = await getSessionCookie();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (cookie != null) 'Cookie': cookie,
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('isLoggedIn');
    await prefs.remove('session_cookie');
    sessionCookie = null;

    try {
      final headers = await getHeaders();
      await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: headers,
      );
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Lấy thông tin user
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }
}