import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // QUAN TRỌNG: Thay YOUR_API_KEY bằng API key thật từ openweathermap.org
  static const String apiKey = '01c4a0bc160ec2b13516dfd4e7e9a2d0';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Lấy thời tiết theo tên thành phố
  static Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric&lang=vi'),
      );

      print('Weather API Response: ${response.statusCode}');
      print('Weather API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'temperature': data['main']['temp'].toDouble(),
          'humidity': data['main']['humidity'].toDouble(),
          'feels_like': data['main']['feels_like'].toDouble(),
          'pressure': data['main']['pressure'],
          'description': data['weather'][0]['description'],
          'icon': data['weather'][0]['icon'],
          'city_name': data['name'],
          'wind_speed': data['wind']['speed'],
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy dữ liệu thời tiết (Code: ${response.statusCode})',
        };
      }
    } catch (e) {
      print('Weather API Error: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Lấy thời tiết theo tọa độ GPS
  static Future<Map<String, dynamic>> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'temperature': data['main']['temp'].toDouble(),
          'humidity': data['main']['humidity'].toDouble(),
          'feels_like': data['main']['feels_like'].toDouble(),
          'description': data['weather'][0]['description'],
          'icon': data['weather'][0]['icon'],
          'city_name': data['name'],
        };
      } else {
        return {'success': false, 'message': 'Không thể lấy dữ liệu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  // Lấy URL icon thời tiết
  static String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}