import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _prefsKey = 'api_base_url';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost/todo_api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2/todo_api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost/todo_api';
    }
  }

  static Future<String> getBaseUrl() async {
    if (_overrideBaseUrl.isNotEmpty) {
      return _sanitize(_overrideBaseUrl);
    }

    await init();
    final saved = _prefs?.getString(_prefsKey);

    if (saved != null && saved.trim().isNotEmpty) {
      return _sanitize(saved);
    }

    return defaultBaseUrl;
  }

  static Future<void> saveBaseUrl(String value) async {
    await init();
    await _prefs!.setString(_prefsKey, _sanitize(value));
  }

  static Future<void> resetBaseUrl() async {
    await init();
    await _prefs!.remove(_prefsKey);
  }

  static String _sanitize(String value) {
    var result = value.trim();

    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }

    return result;
  }
}
