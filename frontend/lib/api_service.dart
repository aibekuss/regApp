import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://172.20.10.3:5000';
  static const String _tokenKey = 'auth_token';

  static Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      bool isEmail = emailOrPhone.contains('@');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          isEmail ? 'email' : 'phone': emailOrPhone,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
        }

        return {
          'success': true,
          'user': data['user'] ?? {},
          'message': data['message'] ?? 'Қош келдіңіз!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Қате логин немесе құпия сөз.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Сервермен байланыс үзілді: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required int age,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'age': age,
          'phone': phone,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Тіркелу сәтті аяқталды!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Тіркелу кезінде қате кетті.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Сервермен байланыс үзілді: $e',
      };
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
