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

  // ➕ ADD (REALTIME)
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    Task? newTask = await _service.addTask(title);

    if (newTask != null) {
      _tasks.insert(0, newTask); // 🔥 langsung muncul
      notifyListeners();
    } else {
      print("ADD GAGAL ❌");
    }
  }

  // ✅ TOGGLE (REALTIME)
  Future<void> toggleTask(Task task) async {
    bool oldValue = task.isDone;

    task.isDone = !task.isDone;
    notifyListeners();

    bool success = await _service.updateTask(task);

    if (!success) {
      task.isDone = oldValue; // rollback
      notifyListeners();
    }
  }

  // 🗑 DELETE (REALTIME)
  Future<void> deleteTask(int id) async {
    Task? removed;

    try {
      removed = _tasks.firstWhere((e) => e.id == id);
    } catch (e) {
      return;
    }

    _tasks.removeWhere((e) => e.id == id);
    notifyListeners();

    bool success = await _service.deleteTask(id);

    if (!success) {
      _tasks.add(removed);
      notifyListeners();
    }

    selectedTask = null;
  }
}
