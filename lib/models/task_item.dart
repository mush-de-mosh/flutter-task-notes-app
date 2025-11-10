class TaskItem {
  final String id;
  final String title;
  final String priority;
  final String description;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.description,
    required this.isCompleted,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      description: json['description'],
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}