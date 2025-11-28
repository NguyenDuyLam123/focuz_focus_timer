class Task {
  final String id;
  final String title;
  int pomodoroCount;

  Task({
    required this.id,
    required this.title,
    this.pomodoroCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'pomodoroCount': pomodoroCount,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        pomodoroCount: json['pomodoroCount'],
      );
}
