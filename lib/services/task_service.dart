import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  final String baseUrl = "http://10.242.113.116/todo_api";

  int? userId;

  // =========================
  // 📥 GET TASK
  // =========================
  Future<List<Task>> getTasks() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_tasks.php?user_id=$userId"),
      );

      print("GET RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Task.fromMap(e)).toList();
      }
    } catch (e) {
      print("ERROR GET: $e");
    }

    return [];
  }

  // =========================
  // ➕ ADD TASK (SUPER FIX)
  // =========================
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
      // 🔥 FIX WAJIB
      final cleanTitle = title.trim();

      if (cleanTitle.isEmpty) {
        print("TITLE KOSONG DARI FLUTTER ❌");
        return null;
      }

      // 🔥 DEBUG (WAJIB ADA)
      print("KIRIM DATA:");
      print("TITLE: $cleanTitle");
      print("USER ID: $userId");

      final response = await http.post(
        Uri.parse("$baseUrl/add_task.php"),
        body: {
          "user_id": userId?.toString() ?? "",
          "title": cleanTitle,
          "isDone": "0",

          "category": category ?? "",
          "time": time ?? "",
          "isUrgent": isUrgent == true ? "1" : "0",
          "isToday": isToday == true ? "1" : "0",

          "deadline": deadline?.toIso8601String() ?? "",

          // 🔥 FITUR BARU
          "days": days?.join(',') ?? "",
          "repeatTime": repeatTime ?? "",
          "isRecurring": isRecurring == true ? "1" : "0",
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print("ADD RESPONSE: ${response.body}");

      // 🔥 CEK RESPONSE KOSONG / HTML
      if (response.body.isEmpty || response.body.startsWith("<")) {
        print("SERVER RETURN HTML / ERROR ❌");
        return null;
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        print("ADD BERHASIL ✅");
        return Task.fromMap(data['data']);
      } else {
        print("SERVER ERROR: ${data['message']}");
      }
    } catch (e) {
      print("ERROR ADD TASK: $e");
    }

    return null;
  }

  // =========================
  // 🔄 UPDATE TASK
  // =========================
  Future<bool> updateTask(Task task) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update_task.php"),
        body: {"id": task.id.toString(), "isDone": task.isDone ? "1" : "0"},
      );

      print("UPDATE RESPONSE: ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      print("ERROR UPDATE: $e");
      return false;
    }
  }

  // =========================
  // 🗑 DELETE TASK
  // =========================
  Future<bool> deleteTask(int id) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/delete_task.php"),
        body: {"id": id.toString()},
      );

      print("DELETE RESPONSE: ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      print("ERROR DELETE: $e");
      return false;
    }
  }
}
