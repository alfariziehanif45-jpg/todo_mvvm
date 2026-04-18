import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  final String baseUrl = "http://192.168.100.10/todo_api";
  // 🔥 TAMBAHAN (WAJIB untuk multi user)
  int? userId;

  // 🔄 GET DATA (BERDASARKAN USER)
  Future<List<Task>> getTasks() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_tasks.php?user_id=$userId"),
      );

      print("GET RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Task.fromMap(e)).toList();
      } else {
        throw Exception("Gagal ambil data");
      }
    } catch (e) {
      print("ERROR GET: $e");
      return [];
    }
  }

  // ➕ ADD TASK (🔥 SUPPORT USER + DEADLINE)
  Future<Task?> addTask(String title, {DateTime? deadline}) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add_task.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId, // 🔥 WAJIB
          "title": title,
          "deadline": deadline?.toIso8601String(),
        }),
      );

      print("ADD RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // ❌ kalau error dari PHP
        if (data["status"] == "error") return null;

        return Task(
          id: int.parse(data['id'].toString()),
          title: data['title'] ?? '',
          isDone: data['isDone'].toString() == '1',
          deadline: data['deadline'] != null
              ? DateTime.tryParse(data['deadline'])
              : null,
        );
      }
    } catch (e) {
      print("ERROR ADD: $e");
    }

    return null;
  }

  // ✅ UPDATE TASK
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

  // 🗑 DELETE TASK
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
