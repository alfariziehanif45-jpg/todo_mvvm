import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../viewmodels/task_viewmodel.dart';

class AppTheme {
  static const Color background = Color(0xFF0E1020);
  static const Color backgroundSoft = Color(0xFF171A2E);
  static const Color panel = Color(0xFF1C2038);
  static const Color panelBorder = Color(0xFF2A2E4A);
  static const Color primary = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFF4F4FF);
  static const Color textSecondary = Color(0xFFB4B7D9);
  static const Color textMuted = Color(0xFF72779A);
}

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final List<String> _filters = const ['Semua', 'Kuliah', 'Proyek', 'Pribadi'];
  String _activeFilter = 'Semua';
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewModel>();
    final visibleTasks = _applyFilter(vm.tasks);
    final todayTasks = _groupTodayTasks(visibleTasks);
    final upcomingTasks = _groupUpcomingTasks(visibleTasks);
    final completedCount = visibleTasks.where((task) => task.isDone).length;
    final progress = visibleTasks.isEmpty ? 0.0 : completedCount / visibleTasks.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B0D18),
              Color(0xFF14182B),
              Color(0xFF0E1020),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -120,
                right: -40,
                child: _GlowOrb(
                  size: 220,
                  colors: const [Color(0xFF8B5CF6), Color(0x002A2E4A)],
                ),
              ),
              Positioned(
                top: 120,
                left: -70,
                child: _GlowOrb(
                  size: 180,
                  colors: const [Color(0xFF14B8A6), Color(0x0014B8A6)],
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: vm.refresh,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                        children: [
                          _HeaderCard(
                            progress: progress,
                            completedCount: completedCount,
                            totalCount: visibleTasks.length,
                          ),
                          const SizedBox(height: 20),
                          _FilterTabs(
                            filters: _filters,
                            activeFilter: _activeFilter,
                            onChanged: (value) {
                              setState(() => _activeFilter = value);
                            },
                          ),
                          const SizedBox(height: 24),
                          if (vm.isLoading && vm.tasks.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 120),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primary,
                                ),
                              ),
                            )
                          else ...[
                            _TaskSection(
                              title: 'Hari ini',
                              emptyText: 'Belum ada tugas untuk hari ini.',
                              tasks: todayTasks,
                            ),
                            const SizedBox(height: 20),
                            _TaskSection(
                              title: 'Berikutnya',
                              emptyText: 'Belum ada tugas berikutnya.',
                              tasks: upcomingTasks,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  _BottomNavigation(
                    currentIndex: _navIndex,
                    onTap: (index) => setState(() => _navIndex = index),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 10,
        onPressed: () => _showAddTaskSheet(context, vm),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Task> _applyFilter(List<Task> tasks) {
    if (_activeFilter == 'Semua') {
      return tasks;
    }

    return tasks.where((task) => _normalizeCategory(task) == _activeFilter).toList();
  }

  List<Task> _groupTodayTasks(List<Task> tasks) {
    final now = DateTime.now();

    return tasks.where((task) {
      if (task.isDone) return false;
      if (task.isToday == true) return true;
      if (task.deadline == null) return true;

      return _isSameDate(task.deadline!, now);
    }).toList();
  }

  List<Task> _groupUpcomingTasks(List<Task> tasks) {
    final now = DateTime.now();

    return tasks.where((task) {
      if (task.isDone) return false;
      if (task.deadline == null) return false;

      return !_isSameDate(task.deadline!, now);
    }).toList();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _normalizeCategory(Task task) {
    final raw = (task.category ?? '').trim().toLowerCase();

    if (raw.contains('kuliah')) return 'Kuliah';
    if (raw.contains('proyek') || raw.contains('project') || raw.contains('coding')) {
      return 'Proyek';
    }
    if (raw.contains('pribadi') || raw.contains('personal')) return 'Pribadi';

    return 'Pribadi';
  }

  Future<void> _showAddTaskSheet(BuildContext context, TaskViewModel vm) async {
    final titleController = TextEditingController();
    String selectedCategory = 'Proyek';
    bool isUrgent = true;
    DateTime? selectedDeadline;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF171A2E),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.panelBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Tambah Task Baru',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat task dengan gaya tampilan baru seperti referensi desain.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: _sheetDecoration('Judul task'),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: AppTheme.panel,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: _sheetDecoration('Kategori'),
                      items: const ['Kuliah', 'Proyek', 'Pribadi']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isUrgent,
                      activeThumbColor: AppTheme.primary,
                      title: const Text(
                        'Prioritas tinggi',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      subtitle: const Text(
                        'Task ditandai dengan titik merah.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      onChanged: (value) {
                        setModalState(() => isUrgent = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await _pickDeadline(context);
                        if (picked == null) return;
                        setModalState(() => selectedDeadline = picked);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.panelBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        selectedDeadline == null
                            ? 'Pilih deadline'
                            : 'Deadline ${_formatDateTime(selectedDeadline!)}',
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Judul task tidak boleh kosong'),
                              ),
                            );
                            return;
                          }

                          await vm.addTask(
                            title,
                            deadline: selectedDeadline,
                            category: selectedCategory,
                            isUrgent: isUrgent,
                            isToday: selectedDeadline == null
                                ? true
                                : _isSameDate(selectedDeadline!, DateTime.now()),
                          );

                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Simpan Task'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
  }

  Future<DateTime?> _pickDeadline(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  InputDecoration _sheetDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.panel,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppTheme.panelBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year} $hour:$minute';
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  final double progress;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1E35), Color(0xFF101326)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Kelompok Mobile',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Project Tasks',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Pantau tugas kelompok dengan tampilan yang lebih modern dan fokus.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _ProgressRing(
            progress: progress,
            completedCount: completedCount,
            totalCount: totalCount,
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  final double progress;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _RingPainter(progress: progress),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'selesai',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF14B8A6), Color(0xFF8B5CF6)],
      ).createShader(Offset.zero & size)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.filters,
    required this.activeFilter,
    required this.onChanged,
  });

  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isActive = filter == activeFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : AppTheme.panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isActive ? Colors.transparent : AppTheme.panelBorder,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.emptyText,
    required this.tasks,
  });

  final String title;
  final String emptyText;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return _SectionShell(
        title: title,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            emptyText,
            style: const TextStyle(color: AppTheme.textMuted),
          ),
        ),
      );
    }

    return _SectionShell(
      title: title,
      child: Column(
        children: tasks
            .map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TaskCard(task: task),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TaskViewModel>();
    final category = _taskCategory(task);
    final accent = _accentColor(category);
    final priority = _priorityColor(task);
    final timeText = _timeText(task);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.panelBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 92,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => vm.toggleTask(task),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isDone ? accent : Colors.transparent,
                        border: Border.all(color: accent, width: 2),
                      ),
                      child: task.isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: task.isDone
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _Badge(label: category, color: accent),
                            _PriorityDot(color: priority),
                            Text(
                              timeText,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => vm.repeatTask(task),
                        icon: const Icon(Icons.refresh_rounded),
                        color: Colors.greenAccent.shade200,
                      ),
                      IconButton(
                        onPressed: task.id == null ? null : () => vm.deleteTask(task.id!),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Colors.redAccent.shade100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _taskCategory(Task task) {
    final raw = (task.category ?? '').trim();
    if (raw.isEmpty) return 'Pribadi';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  static Color _accentColor(String category) {
    switch (category.toLowerCase()) {
      case 'kuliah':
        return AppTheme.warning;
      case 'proyek':
      case 'coding':
        return AppTheme.primary;
      case 'qa':
        return Colors.pinkAccent;
      default:
        return AppTheme.secondary;
    }
  }

  static Color _priorityColor(Task task) {
    if (task.isUrgent == true || task.isExpired) {
      return AppTheme.danger;
    }

    if (task.deadline != null) {
      final remaining = task.deadline!.difference(DateTime.now());
      if (remaining.inHours <= 24) {
        return AppTheme.warning;
      }
    }

    return AppTheme.secondary;
  }

  static String _timeText(Task task) {
    if (task.deadline != null) {
      final hour = task.deadline!.hour.toString().padLeft(2, '0');
      final minute = task.deadline!.minute.toString().padLeft(2, '0');
      return '${task.isExpired ? 'Terlambat' : 'Deadline'} $hour:$minute';
    }

    return task.time?.isNotEmpty == true ? task.time! : 'Fleksibel';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.dashboard_rounded, 'Tasks'),
      (Icons.calendar_today_rounded, 'Jadwal'),
      (Icons.person_outline_rounded, 'Profil'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111427),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          final item = items[index];

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$1,
                      color: isActive ? AppTheme.primary : AppTheme.textMuted,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: isActive ? 18 : 0,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
