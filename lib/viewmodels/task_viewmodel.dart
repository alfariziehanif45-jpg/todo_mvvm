import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Task? selectedTask;
  bool isLoading = false;

  TaskViewModel() {
    loadTasks();
  }

  // 🔄 LOAD DATA
  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    try {
      _tasks = await _service.getTasks();
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

  // ➕ ADD TASK (🔥 FIX TOTAL)
  Future<void> addTask(String title, {DateTime? deadline}) async {
    final newTask = await _service.addTask(title, deadline: deadline);

    if (newTask != null) {
      _tasks.add(newTask); // 🔥 INI YANG KAMU BELUM ADA
      notifyListeners(); // 🔥 BIAR UI UPDATE
    }
  }

  // ✅ TOGGLE TASK (REALTIME TANPA RELOAD)
  Future<void> toggleTask(Task task) async {
    bool oldValue = task.isDone;

    task.isDone = !task.isDone;
    notifyListeners();

    bool success = await _service.updateTask(task);

    if (!success) {
      task.isDone = oldValue; // rollback
      notifyListeners();
      print("UPDATE GAGAL ❌");
    }
  }

  // 🗑 DELETE TASK (REALTIME TANPA RELOAD)
  Future<void> deleteTask(int id) async {
    List<Task> oldTasks = List.from(_tasks);

    _tasks.removeWhere((e) => e.id == id);
    notifyListeners();

    bool success = await _service.deleteTask(id);

    if (!success) {
      _tasks = oldTasks; // rollback
      notifyListeners();
      print("DELETE GAGAL ❌");
    } else {
      print("DELETE BERHASIL ✅");
    }

    selectedTask = null;
  }
}
