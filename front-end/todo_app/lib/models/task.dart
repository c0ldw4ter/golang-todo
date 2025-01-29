class Task {
  final String id;
  final String title;
  final String description;
  bool completed;

  Task(
      {required this.id,
      required this.title,
      required this.description,
      required this.completed});

  factory Task.fromJson(Map<String, dynamic> json) {
    // Убедитесь, что ID всегда будет строкой
    final id = json['_id']?.toString() ?? '';
    return Task(
      id: id,
      title: json['title'],
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
    };
  }
}
