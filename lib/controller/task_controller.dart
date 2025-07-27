import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/task.dart';

class TaskController extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  TaskController() {
    _loadTasks();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];

    _tasks.clear();
    for (final taskJson in tasksJson) {
      try {
        final taskMap = json.decode(taskJson);
        _tasks.add(
          Task(
            title: taskMap['title'],
            isCompleted: taskMap['isCompleted'] ?? false,
            createdAt: DateTime.parse(taskMap['createdAt']),
            minutesSpent: taskMap['minutesSpent'] ?? 0,
          ),
        );
      } catch (e) {
        print('Error loading task: $e');
      }
    }
    notifyListeners();
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks
        .map(
          (task) => json.encode({
            'title': task.title,
            'isCompleted': task.isCompleted,
            'createdAt': task.createdAt.toIso8601String(),
            'minutesSpent': task.minutesSpent,
          }),
        )
        .toList();

    await prefs.setStringList('tasks', tasksJson);
  }

  void addTask(String title) {
    _tasks.add(Task(title: title));
    _saveTasks();
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(int index) {
    final task = _tasks[index];
    final wasCompleted = task.isCompleted;
    task.isCompleted = !task.isCompleted;

    // If task is being completed (not uncompleted), record the time spent
    if (!wasCompleted && task.isCompleted) {
      print(
        'Task "${task.title}" completed with ${task.minutesSpent} minutes spent',
      );
    }

    _saveTasks();
    notifyListeners();
  }

  // Add minutes to a specific task (called when Pomodoro completes)
  void addMinutesToTask(int taskIndex, int minutes) {
    print(
      'addMinutesToTask called - index: $taskIndex, minutes: $minutes, total tasks: ${_tasks.length}',
    );
    if (taskIndex >= 0 && taskIndex < _tasks.length) {
      final oldMinutes = _tasks[taskIndex].minutesSpent;
      _tasks[taskIndex].minutesSpent += minutes;
      print(
        'Added $minutes minutes to task "${_tasks[taskIndex].title}" ($oldMinutes -> ${_tasks[taskIndex].minutesSpent} minutes)',
      );
      _saveTasks();
      notifyListeners();
    } else {
      print(
        'Invalid task index: $taskIndex (valid range: 0-${_tasks.length - 1})',
      );
    }
  }

  // Get the index of the first uncompleted task (for time tracking)
  int? getFirstUncompletedTaskIndex() {
    print(
      'getFirstUncompletedTaskIndex called - Total tasks: ${_tasks.length}',
    );
    for (int i = 0; i < _tasks.length; i++) {
      print(
        'Task $i: "${_tasks[i].title}" - Completed: ${_tasks[i].isCompleted}',
      );
      if (!_tasks[i].isCompleted) {
        print('Found uncompleted task at index $i');
        return i;
      }
    }
    print('No uncompleted tasks found');
    return null; // All tasks completed
  }

  // Get tasks for a specific date
  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Get all tasks sorted by creation date (newest first)
  List<Task> get allTasksSorted =>
      List.from(_tasks)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
