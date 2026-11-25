import 'package:flutter/material.dart';
import '../models/study_task.dart';

enum TaskPriority {
  overdue,
  urgent,
  medium,
  low,
  completed,
}

class PriorityHelper {
  static TaskPriority calculatePriority(StudyTask task) {
    if (task.isCompleted) {
      return TaskPriority.completed;
    }

    final today = DateTime.now();

    final todayDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final deadlineDate = DateTime(
      task.deadline.year,
      task.deadline.month,
      task.deadline.day,
    );

    final difference = deadlineDate.difference(todayDate).inDays;

    if (difference < 0) {
      return TaskPriority.overdue;
    }

    if (difference <= 1) {
      return TaskPriority.urgent;
    }

    if (difference <= 3) {
      return TaskPriority.medium;
    }

    return TaskPriority.low;
  }

  static String getLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.overdue:
        return 'En retard';

      case TaskPriority.urgent:
        return 'Urgente';

      case TaskPriority.medium:
        return 'Moyenne';

      case TaskPriority.low:
        return 'Faible';

      case TaskPriority.completed:
        return 'Terminée';
    }
  }

  static Color getColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.overdue:
        return Colors.red;

      case TaskPriority.urgent:
        return Colors.orange;

      case TaskPriority.medium:
        return Colors.amber;

      case TaskPriority.low:
        return Colors.blue;

      case TaskPriority.completed:
        return Colors.green;
    }
  }

  static IconData getIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.overdue:
        return Icons.warning;

      case TaskPriority.urgent:
        return Icons.priority_high;

      case TaskPriority.medium:
        return Icons.schedule;

      case TaskPriority.low:
        return Icons.low_priority;

      case TaskPriority.completed:
        return Icons.check_circle;
    }
  }
}
