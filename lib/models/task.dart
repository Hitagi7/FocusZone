class Task {
  String title;
  bool isCompleted;
  DateTime createdAt;
  int minutesSpent; // Track minutes spent on this task

  Task({required this.title, this.isCompleted = false, DateTime? createdAt, this.minutesSpent = 0}) 
      : createdAt = createdAt ?? DateTime.now();
} 