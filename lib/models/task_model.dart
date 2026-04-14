class Task {
  int? id;
  String title;
  bool isDone;

  String? category;
  String? time;
  bool? isUrgent;
  bool? isToday;

  DateTime? deadline; // 🔥 DEADLINE

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    this.category,
    this.time,
    this.isUrgent,
    this.isToday,
    this.deadline,
  });

  // 🔥 FROM API
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: int.tryParse(map['id'].toString()),
      title: map['title'] ?? '',

      isDone: map['isDone'].toString() == '1',

      category: map['category'],
      time: map['time'],

      isUrgent: map['isUrgent']?.toString() == '1',
      isToday: map['isToday']?.toString() == '1',

      // 🔥 FIX DEADLINE (AMAN)
      deadline: (map['deadline'] != null && map['deadline'] != '')
          ? DateTime.tryParse(map['deadline'])
          : null,
    );
  }

  // 🔥 TO API
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
    };
  }

  // 🔥 CEK TASK TELAT
  bool get isExpired {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isDone;
  }

  // 🔥 FORMAT DEADLINE (BIAR RAPI DI UI)
  String get deadlineFormatted {
    if (deadline == null) return "-";

    return "${deadline!.day.toString().padLeft(2, '0')}/"
        "${deadline!.month.toString().padLeft(2, '0')}/"
        "${deadline!.year} "
        "${deadline!.hour.toString().padLeft(2, '0')}:"
        "${deadline!.minute.toString().padLeft(2, '0')}";
  }

  // 🔥 CEK SISA WAKTU (OPTIONAL)
  Duration? get remainingTime {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now());
  }
}
