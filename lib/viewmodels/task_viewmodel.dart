import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Task? selectedTask;
  bool isLoading = false;

  // 🔥 CONSTRUCTOR (WAJIB USER ID)
  TaskViewModel(int userId) {
    _service.userId = userId;
    loadTasks();
  }

  // =========================
  // 🔄 LOAD TASK
  // =========================
  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getTasks();

      if (result.isNotEmpty) {
        _tasks = result;
      }
    } catch (e) {
      print("ERROR LOAD: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // =========================
  // 🎯 SELECT TASK
  // =========================
  void selectTask(Task task) {
    selectedTask = task;
    notifyListeners();
  }

  // =========================
  // ➕ ADD TASK (VERSI LENGKAP)
  // =========================
  Future<void> addTask(String title, {DateTime? deadline}) async {
    final newTask = await _service.addTask(title, deadline: deadline);

    if (newTask != null) {
      _tasks.insert(0, newTask); // 🔥 TAMBAH LANGSUNG KE LIST
      notifyListeners(); // 🔥 REFRESH UI
      print("TASK BERHASIL DITAMBAH ✅");
    } else {
      print("ADD GAGAL ❌");
    }
  }

  // =========================
  // 🔁 REPEAT TASK (UPGRADE)
  // =========================
  Future<void> repeatTask(Task task) async {
    final newTask = await _service.addTask(
      task.title,

      // 🔥 bawa semua data lama
      deadline: task.deadline,
      category: task.category,
      time: task.time,
      isUrgent: task.isUrgent,
      isToday: task.isToday,

      days: task.days,
      repeatTime: task.repeatTime,
      isRecurring: task.isRecurring,
    );

    if (newTask != null) {
      _tasks.insert(0, newTask);
      notifyListeners();
      print("TASK DIULANG ✅");
    } else {
      print("GAGAL ULANG ❌");
    }
  }

  // =========================
  // 🔥 AUTO GENERATE TASK HARIAN
  // =========================
  void generateTodayTasks() {
    final today = DateTime.now().weekday; // 1=Mon

    final todayName = _mapDay(today);

    final newTasks = _tasks.where((task) {
      return task.isRecurring == true &&
          task.days != null &&
          task.days!.contains(todayName);
    }).toList();

    for (var task in newTasks) {
      _tasks.insert(
        0,
        Task(
          title: task.title,
          deadline: task.deadline,
          category: task.category,
          time: task.repeatTime,
        ),
      );
    }

    notifyListeners();
  }

  String _mapDay(int day) {
    const map = {
      1: "Mon",
      2: "Tue",
      3: "Wed",
      4: "Thu",
      5: "Fri",
      6: "Sat",
      7: "Sun",
    };
    return map[day]!;
  }

  // =========================
  // ✅ TOGGLE TASK
  // =========================
  Future<void> toggleTask(Task task) async {
    bool oldValue = task.isDone;

    task.isDone = !task.isDone;
    notifyListeners();

    bool success = await _service.updateTask(task);

    if (!success) {
      task.isDone = oldValue;
      notifyListeners();
      print("UPDATE GAGAL ❌");
    } else {
      print("UPDATE BERHASIL ✅");
    }
  }

  // =========================
  // 🗑 DELETE TASK
  // =========================
  Future<void> deleteTask(int id) async {
    List<Task> oldTasks = List.from(_tasks);

    _tasks.removeWhere((e) => e.id == id);
    notifyListeners();

    bool success = await _service.deleteTask(id);

    if (!success) {
      _tasks = oldTasks;
      notifyListeners();
      print("DELETE GAGAL ❌");
    } else {
      print("DELETE BERHASIL ✅");
    }

    selectedTask = null;
  }

  // =========================
  // 🔄 REFRESH
  // =========================
  Future<void> refresh() async {
    await loadTasks();
  }
}
