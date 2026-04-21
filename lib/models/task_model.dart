class Task {
  int? id;
  String title;
  bool isDone;

  String? category;
  String? time;
  bool? isUrgent;
  bool? isToday;

  DateTime? deadline;

  // 🔥 FITUR BARU (REPEAT + HARIAN)
  List<String>? days; // contoh: ["Mon", "Tue"]
  String? repeatTime; // jam pengulangan
  bool? isRecurring; // apakah task berulang

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    this.category,
    this.time,
    this.isUrgent,
    this.isToday,
    this.deadline,
    this.days,
    this.repeatTime,
    this.isRecurring,
  });

  // =========================
  // 🔄 FROM API
  // =========================
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: int.tryParse(map['id'].toString()),
      title: map['title'] ?? '',

      isDone: map['isDone'].toString() == '1',

      category: map['category'],
      time: map['time'],

      isUrgent: map['isUrgent']?.toString() == '1',
      isToday: map['isToday']?.toString() == '1',

      // 🔥 DEADLINE SAFE PARSE
      deadline: (map['deadline'] != null && map['deadline'] != '')
          ? DateTime.tryParse(map['deadline'])
          : null,

      // 🔥 FIX: STRING → LIST
      days: (map['days'] != null && map['days'] != '')
          ? (map['days'] as String).split(',')
          : [],

      repeatTime: map['repeatTime'],

      isRecurring: map['isRecurring']?.toString() == '1',
    );
  }

  // =========================
  // 📤 TO API
  // =========================
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "isDone": isDone ? "1" : "0",
      "category": category,
      "time": time,
      "isUrgent": isUrgent == true ? "1" : "0",
      "isToday": isToday == true ? "1" : "0",
      "deadline": deadline?.toIso8601String(),

      // 🔥 LIST → STRING (WAJIB BIAR MASUK DB)
      "days": (days != null && days!.isNotEmpty) ? days!.join(',') : "",

      "repeatTime": repeatTime,
      "isRecurring": isRecurring == true ? "1" : "0",
    };
  }

  // =========================
  // ⏰ CEK TELAT
  // =========================
  bool get isExpired {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isDone;
  }

  // =========================
  // 📅 FORMAT DEADLINE
  // =========================
  String get deadlineFormatted {
    if (deadline == null) return "-";

    return "${deadline!.day.toString().padLeft(2, '0')}/"
        "${deadline!.month.toString().padLeft(2, '0')}/"
        "${deadline!.year} "
        "${deadline!.hour.toString().padLeft(2, '0')}:"
        "${deadline!.minute.toString().padLeft(2, '0')}";
  }

  // =========================
  // 📆 FORMAT HARI
  // =========================
  String get daysFormatted {
    if (days == null || days!.isEmpty) return "-";
    return days!.join(', ');
  }

  // =========================
  // ⏳ SISA WAKTU
  // =========================
  Duration? get remainingTime {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now());
  }
}
