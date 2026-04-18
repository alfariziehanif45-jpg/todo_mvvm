import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Task? selectedTask;
  bool isLoading = false;

  // 🔥 WAJIB: TERIMA userId dari login
  TaskViewModel(int userId) {
    _service.userId = userId;
    loadTasks();
  }

  // 🔄 LOAD DATA (ANTI ERROR)
  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getTasks();

      // 🔥 FIX: biar gak overwrite dengan kosong
      if (result.isNotEmpty) {
        _tasks = result;
      }
    } catch (e) {
      print("ERROR LOAD: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // 🎯 SELECT TASK
  void selectTask(Task task) {
    selectedTask = task;
    notifyListeners();
  }

  // ➕ ADD TASK (🔥 SUPER STABLE)
  Future<void> addTask(String title, {DateTime? deadline}) async {
    if (title.trim().isEmpty) return;

    final newTask = await _service.addTask(title, deadline: deadline);

    if (newTask != null) {
      _tasks.insert(0, newTask); // 🔥 langsung muncul di atas
      notifyListeners();
      print("ADD BERHASIL ✅");
    } else {
      print("ADD GAGAL ❌");
    }
  }

  // ✅ TOGGLE TASK (REALTIME + ROLLBACK)
  Future<void> toggleTask(Task task) async {
    bool oldValue = task.isDone;

    task.isDone = !task.isDone;
    notifyListeners();

    bool success = await _service.updateTask(task);

    if (!success) {
      task.isDone = oldValue; // 🔥 rollback kalau gagal
      notifyListeners();
      print("UPDATE GAGAL ❌");
    } else {
      print("UPDATE BERHASIL ✅");
    }
  }

  // 🗑 DELETE TASK (REALTIME + ROLLBACK)
  Future<void> deleteTask(int id) async {
    List<Task> oldTasks = List.from(_tasks);

    _tasks.removeWhere((e) => e.id == id);
    notifyListeners();

    bool success = await _service.deleteTask(id);

    if (!success) {
      _tasks = oldTasks; // 🔥 rollback
      notifyListeners();
      print("DELETE GAGAL ❌");
    } else {
      print("DELETE BERHASIL ✅");
    }

    selectedTask = null;
  }

  // 🔄 OPTIONAL: REFRESH MANUAL
  Future<void> refresh() async {
    await loadTasks();
  }
}
