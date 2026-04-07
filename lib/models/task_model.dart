class Task {
  int? id;
  String title;
  bool isDone;

  String? category;
  String? time;
  bool? isUrgent;
  bool? isToday;

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    this.category,
    this.time,
    this.isUrgent,
    this.isToday,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: int.parse(map['id'].toString()),
      title: map['title'],
      isDone: map['isDone'].toString() == '1',
      category: map['category'],
      time: map['time'],
      isUrgent: map['isUrgent'] == '1',
      isToday: map['isToday'] == '1',
    );
  }
}
