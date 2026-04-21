import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.242.113.116/todo_api";

  // 🔐 LOGIN (return userId)
  Future<int?> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      print("LOGIN RESPONSE: ${res.body}");

      if (res.body.isEmpty) return null; // 🔥 ANTI ERROR

      final data = jsonDecode(res.body);

      if (data["status"] == "success") {
        return int.parse(data["user_id"].toString());
      }

      return null;
    } catch (e) {
      print("ERROR LOGIN: $e");
      return null;
    }
  }

  // 📝 REGISTER (INI YANG KAMU TANYA)
  Future<bool> register(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/register.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(res.body);

      return data["status"] == "success";
    } catch (e) {
      print("ERROR REGISTER: $e");
      return false;
    }
  }
}
