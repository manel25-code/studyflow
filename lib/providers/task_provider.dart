import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/study_task.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseHelper _database = DatabaseHelper.instance;

  List<StudyTask> _tasks = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<StudyTask> get tasks => List.unmodifiable(_tasks);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get totalTasks => _tasks.length;

  int get completedTasks {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).length;
  }

  int get overdueTasks {
    final today = DateTime.now();

    final todayDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

    return _tasks.where((task) {
      if (task.isCompleted) {
        return false;
      }

      final deadlineDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );

      return deadlineDate.isBefore(todayDate);
    }).length;
  }

  double get progress {
    if (_tasks.isEmpty) {
      return 0;
    }

    return completedTasks / totalTasks;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _database.getTasks();
    } catch (e) {
      _errorMessage = 'Impossible de charger les tâches.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(StudyTask task) async {
    try {
      final id = await _database.insertTask(task);

      final newTask = task.copyWith(id: id);

      _tasks.add(newTask);
      _sortTasks();

      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('ERREUR AJOUT TACHE : $e');
      debugPrint('$stackTrace');

      _errorMessage = 'Impossible d’ajouter la tâche.';
      notifyListeners();

      rethrow;
    }
  }

  Future<void> updateTask(StudyTask task) async {
    try {
      await _database.updateTask(task);

      final index = _tasks.indexWhere(
        (item) => item.id == task.id,
      );

      if (index != -1) {
        _tasks[index] = task;
      }

      _sortTasks();

      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de modifier la tâche.';
      notifyListeners();

      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _database.deleteTask(id);

      _tasks.removeWhere(
        (task) => task.id == id,
      );

      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de supprimer la tâche.';
      notifyListeners();

      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(StudyTask task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    await updateTask(updatedTask);
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      return a.deadline.compareTo(b.deadline);
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
