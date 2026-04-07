import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  final String baseUrl = "http://10.55.174.116/todo_api";

  // 🔄 GET DATA
  Future<List<Task>> getTasks() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/get_tasks.php"));

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

  // ➕ ADD (🔥 RETURN TASK + ID)
  Future<Task?> addTask(String title) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add_task.php"),
        body: {"title": title},
      );

      print("ADD RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        return Task(
          id: int.parse(data['id'].toString()),
          title: data['title'],
          isDone: data['isDone'] == 1,
        );
      } else {
        return null;
      }
    } catch (e) {
      print("ERROR ADD: $e");
      return null;
    }
  }

  // ✅ UPDATE
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

  // 🗑 DELETE
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
