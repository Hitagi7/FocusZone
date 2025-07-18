import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';

class TaskList extends StatelessWidget {
  final TaskController taskController;
  const TaskList({super.key, required this.taskController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: taskController,
      builder: (context, child) {
        final tasks = taskController.tasks;
        return Container(
          constraints: BoxConstraints(
            maxHeight: 120.0, // Always show space for 2 tasks
            minHeight: 120.0, // Always show space for 2 tasks
          ),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks yet. Add one below!',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      tileColor: Colors.white.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) => taskController.toggleTask(index),
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: task.isCompleted ? Colors.white : null,
                          decorationThickness: task.isCompleted ? 2.0 : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => taskController.removeTask(index),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
} 