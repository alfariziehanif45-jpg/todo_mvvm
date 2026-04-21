import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onRepeat;
  final VoidCallback onTap;
  final bool isSelected;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onRepeat,
    required this.onTap,
    required this.isSelected,
  });

  bool get isOverdue {
    if (task.deadline == null) return false;
    return DateTime.now().isAfter(task.deadline!) && !task.isDone;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isOverdue ? Colors.red : Colors.white24),
        ),
        child: ListTile(
          // ✅ CHECK
          leading: GestureDetector(
            onTap: onToggle,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: task.isDone ? Colors.purple : Colors.transparent,
              child: task.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),

          // ✅ TITLE
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isDone ? Colors.grey : Colors.white,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),

          // ✅ SUBTITLE (DEADLINE + HARI)
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.deadline != null)
                Text(
                  "Deadline: ${task.deadlineFormatted}",
                  style: const TextStyle(fontSize: 11),
                ),

              if (task.days != null && task.days!.isNotEmpty)
                Text(
                  "Hari: ${task.daysFormatted}",
                  style: const TextStyle(fontSize: 11),
                ),
            ],
          ),

          // ✅ ACTION
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onRepeat,
                child: const Icon(Icons.refresh, color: Colors.green),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
