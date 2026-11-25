import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static const String _storageKey = 'studyflow_tasks';

  DatabaseHelper._init();

  Future<List<StudyTask>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String? storedData = prefs.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(storedData);

    final tasks = decodedData.map((item) {
      return StudyTask.fromMap(
        Map<String, dynamic>.from(item),
      );
    }).toList();

    tasks.sort(
      (a, b) => a.deadline.compareTo(b.deadline),
    );

    return tasks;
  }

  Future<int> insertTask(StudyTask task) async {
    final tasks = await getTasks();

    int newId = 1;

    if (tasks.isNotEmpty) {
      newId =
          tasks.map((task) => task.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }

    final newTask = task.copyWith(id: newId);

    tasks.add(newTask);

    await _saveTasks(tasks);

    return newId;
  }

  Future<int> updateTask(StudyTask task) async {
    final tasks = await getTasks();

    final index = tasks.indexWhere(
      (item) => item.id == task.id,
    );

    if (index == -1) {
      return 0;
    }

    tasks[index] = task;

    await _saveTasks(tasks);

    return 1;
  }

  Future<int> deleteTask(int id) async {
    final tasks = await getTasks();

    final initialLength = tasks.length;

    tasks.removeWhere(
      (task) => task.id == id,
    );

    if (tasks.length == initialLength) {
      return 0;
    }

    await _saveTasks(tasks);

    return 1;
  }

  Future<int> deleteAllTasks() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);

    return 1;
  }

  Future<void> _saveTasks(List<StudyTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> taskMaps =
        tasks.map((task) => task.toMap()).toList();

    final String encodedData = jsonEncode(taskMaps);

    await prefs.setString(_storageKey, encodedData);
  }
}
