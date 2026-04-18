import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../models/task_model.dart';

// ─── THEME ─────────────────────────────────────────────
class AppTheme {
  static const Color bgDark = Color(0xFF12131A);
  static const Color cardDark = Color(0xFF1C1E2A);

  static const Color accent = Color(0xFF7C5CFC);
  static const Color accentLight = Color(0xFF9B7DFF);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8A8FA8);
  static const Color textMuted = Color(0xFF4E5270);
}

// ─── TASK CARD ─────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.isSelected,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  bool get isOverdue {
    if (task.deadline == null) return false;
    return DateTime.now().isAfter(task.deadline!) && !task.isDone;
  }

  String formatDeadline(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? Colors.redAccent
                  : Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ListTile(
            // ✅ CHECKLIST
            leading: GestureDetector(
              onTap: onToggle,
              child: AnimatedScale(
                scale: task.isDone ? 1.2 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone ? AppTheme.accent : Colors.transparent,
                    border: Border.all(
                      color: task.isDone ? AppTheme.accent : AppTheme.textMuted,
                      width: 2,
                    ),
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),

            // ✅ TITLE + DEADLINE
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: isOverdue
                        ? Colors.redAccent
                        : (task.isDone
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary),
                    decoration: task.isDone || isOverdue
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Colors.red,
                  ),
                ),

                if (task.deadline != null)
                  Text(
                    "Deadline: ${formatDeadline(task.deadline!)}",
                    style: TextStyle(
                      fontSize: 11,
                      color: isOverdue ? Colors.red : Colors.white54,
                    ),
                  ),
              ],
            ),

            // ✅ ACTION (STAR + DELETE)
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_border, color: Colors.white54),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── MAIN VIEW ─────────────────────────────────────────
class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final TextEditingController _controller = TextEditingController();

  // 🔥 PICK DEADLINE (REAL TIME)
  Future<DateTime?> pickDeadline() async {
    DateTime now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F111A), Color(0xFF1A1D2E), Color(0xFF12131A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Text(
                        "Halo 👋",
                        style: TextStyle(
                          color: AppTheme.accentLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "My Tasks",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // INPUT
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: AppTheme.accent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Tambah tugas...",
                                  hintStyle: TextStyle(color: Colors.white38),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_controller.text.isEmpty) return;

                                DateTime? deadline = await pickDeadline();

                                await vm.addTask(
                                  _controller.text,
                                  deadline: deadline,
                                );

                                _controller.clear();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LIST
                      Expanded(
                        child: vm.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: vm.tasks.length,
                                itemBuilder: (context, i) {
                                  final task = vm.tasks[i];
                                  return _TaskCard(
                                    task: task,
                                    isSelected: vm.selectedTask?.id == task.id,
                                    onTap: () => vm.selectTask(task),
                                    onToggle: () => vm.toggleTask(task),
                                    onDelete: () {
                                      if (task.id != null) {
                                        vm.deleteTask(task.id!);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // BOTTOM NAV
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.home, color: AppTheme.accent),
                    Icon(Icons.calendar_today, color: Colors.white54),
                    Icon(Icons.person, color: Colors.white54),
                    Icon(Icons.settings, color: Colors.white54),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
