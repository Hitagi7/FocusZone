import 'package:flutter/material.dart';
import '../controller/task_controller.dart';

class TaskAdd extends StatefulWidget {
  final TaskController taskController;
  const TaskAdd({super.key, required this.taskController});

  @override
  State<TaskAdd> createState() => _TaskAddState();
}

class _TaskAddState extends State<TaskAdd> {
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.taskController.addTask(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: _controller,
          style: TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Add a new task...',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 11),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          ),
          onSubmitted: (_) => _addTask(),
        ),
      ),
    );
  }
}
