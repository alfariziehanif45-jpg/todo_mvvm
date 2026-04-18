import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _service = AuthService();

  int? userId;
  bool isLoading = false;

  Future<bool> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    userId = await _service.login(username, password);

    isLoading = false;
    notifyListeners();

    return userId != null;
  }
}
