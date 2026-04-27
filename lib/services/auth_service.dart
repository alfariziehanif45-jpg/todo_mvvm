import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AuthService {
  Future<int?> login(String username, String password) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('LOGIN URL: $baseUrl/login.php');
      print('LOGIN RESPONSE: ${res.body}');

      if (res.body.isEmpty) return null;

      final data = jsonDecode(res.body);

      if (data['status'] == 'success') {
        return int.parse(data['user_id'].toString());
      }

      return null;
    } catch (e) {
      print('ERROR LOGIN: $e');
      print(
        'CEK API_BASE_URL / server PHP / koneksi jaringan / CORS jika jalan di web',
      );
      return null;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http
          .post(
            Uri.parse('$baseUrl/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('REGISTER URL: $baseUrl/register.php');
      final data = jsonDecode(res.body);

      return data['status'] == 'success';
    } catch (e) {
      print('ERROR REGISTER: $e');
      print(
        'CEK API_BASE_URL / server PHP / koneksi jaringan / CORS jika jalan di web',
      );
      return false;
    }
  }
}
