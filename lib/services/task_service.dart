import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/task_model.dart';

class TaskService {
  int? userId;

  Future<List<Task>> getTasks() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http
          .get(Uri.parse('$baseUrl/get_tasks.php?user_id=$userId'))
          .timeout(const Duration(seconds: 15));

      print('GET URL: $baseUrl/get_tasks.php?user_id=$userId');
      print('GET RESPONSE: ${res.body}');

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Task.fromMap(e)).toList();
      }
    } catch (e) {
      print('ERROR GET: $e');
      print(
        'CEK API_BASE_URL / server PHP / koneksi jaringan / CORS jika jalan di web',
      );
    }

    return [];
  }

  Future<Task?> addTask(
    String title, {
    DateTime? deadline,
    String? category,
    String? time,
    bool? isUrgent,
    bool? isToday,
    List<String>? days,
    String? repeatTime,
    bool? isRecurring,
  }) async {
    try {
      final cleanTitle = title.trim();
      if (cleanTitle.isEmpty) {
        print('TITLE KOSONG DARI FLUTTER');
        return null;
      }

      final baseUrl = await ApiConfig.getBaseUrl();

      print('KIRIM DATA:');
      print('TITLE: $cleanTitle');
      print('USER ID: $userId');

      final response = await http
          .post(
            Uri.parse('$baseUrl/add_task.php'),
            body: {
              'user_id': userId?.toString() ?? '',
              'title': cleanTitle,
              'isDone': '0',
              'category': category ?? '',
              'time': time ?? '',
              'isUrgent': isUrgent == true ? '1' : '0',
              'isToday': isToday == true ? '1' : '0',
              'deadline': deadline?.toIso8601String() ?? '',
              'days': days?.join(',') ?? '',
              'repeatTime': repeatTime ?? '',
              'isRecurring': isRecurring == true ? '1' : '0',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('ADD URL: $baseUrl/add_task.php');
      print('STATUS CODE: ${response.statusCode}');
      print('ADD RESPONSE: ${response.body}');

      if (response.body.isEmpty || response.body.startsWith('<')) {
        print('SERVER RETURN HTML / ERROR');
        return null;
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        print('ADD BERHASIL');
        return Task.fromMap(data['data']);
      }

      print('SERVER ERROR: ${data['message']}');
    } catch (e) {
      print('ERROR ADD TASK: $e');
      print(
        'CEK API_BASE_URL / server PHP / koneksi jaringan / CORS jika jalan di web',
      );
    }

    return null;
  }

  Future<bool> updateTask(Task task) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http
          .post(
            Uri.parse('$baseUrl/update_task.php'),
            body: {
              'id': task.id.toString(),
              'isDone': task.isDone ? '1' : '0',
            },
          )
          .timeout(const Duration(seconds: 15));

      print('UPDATE URL: $baseUrl/update_task.php');
      print('UPDATE RESPONSE: ${res.body}');

      return res.statusCode == 200;
    } catch (e) {
      print('ERROR UPDATE: $e');
      print(
        'CEK API_BASE_URL / server PHP / koneksi jaringan / CORS jika jalan di web',
      );
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final res = await http
          .post(
            Uri.parse('$baseUrl/delete_task.php'),
            body: {'id': id.toString()},
          )
          .timeout(const Duration(seconds: 15));

      print('DELETE URL: $baseUrl/delete_task.php');
      print('DELETE RESPONSE: ${res.body}');

      return res.statusCode == 200;
    } catch (e) {
      print('ERROR DELETE: $e');
      print(
        'CEK API_BASE_URL / server PHP / koneksi jaringan / CORS jika jalan di web',
      );
      return false;
    }
  }
}
