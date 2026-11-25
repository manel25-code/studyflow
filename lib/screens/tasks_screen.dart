import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_task.dart';
import '../providers/task_provider.dart';
import '../utils/priority_helper.dart';

class TasksScreen extends StatefulWidget {
  final VoidCallback onAddTask;
  final Function(StudyTask) onEditTask;

  const TasksScreen({
    super.key,
    required this.onAddTask,
    required this.onEditTask,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'Toutes';
  String _searchQuery = '';

  final List<String> _filters = [
    'Toutes',
    'En cours',
    'Terminées',
  ];

  List<StudyTask> _filterTasks(List<StudyTask> tasks) {
    return tasks.where((task) {
      bool matchesFilter;

      if (_selectedFilter == 'En cours') {
        matchesFilter = !task.isCompleted;
      } else if (_selectedFilter == 'Terminées') {
        matchesFilter = task.isCompleted;
      } else {
        matchesFilter = true;
      }

      final query = _searchQuery.toLowerCase().trim();

      final matchesSearch = task.title.toLowerCase().contains(query) ||
          task.subject.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _confirmDelete(StudyTask task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer la tâche ?'),
          content: Text(
            'Veux-tu vraiment supprimer "${task.title}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await context.read<TaskProvider>().deleteTask(task.id!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tâche supprimée avec succès.'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    final allTasks = provider.tasks;

    final filteredTasks = _filterTasks(allTasks);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF3576BC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 35,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mes tâches',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${provider.totalTasks} tâche(s) • '
                        '${provider.completedTasks} terminée(s)',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une tâche ou matière...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];

                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: const Color(0xFF3576BC),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: provider.loadTasks,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            100,
                          ),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];

                            return _buildTaskCard(task);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddTask,
        backgroundColor: const Color(0xFF3576BC),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildTaskCard(StudyTask task) {
    final priority = PriorityHelper.calculatePriority(task);

    final priorityColor = PriorityHelper.getColor(priority);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    context.read<TaskProvider>().toggleTaskCompletion(task);
                  },
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      widget.onEditTask(task);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Colors.grey
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            task.subject,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _formatDate(task.deadline),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.onEditTask(task);
                    } else if (value == 'delete') {
                      _confirmDelete(task);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PriorityHelper.getIcon(priority),
                      size: 15,
                      color: priorityColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      PriorityHelper.getLabel(priority),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;

    if (_searchQuery.isNotEmpty) {
      message = 'Aucune tâche ne correspond à ta recherche.';
    } else if (_selectedFilter == 'Terminées') {
      message = 'Tu n’as pas encore terminé de tâche.';
    } else if (_selectedFilter == 'En cours') {
      message = 'Toutes tes tâches sont terminées !';
    } else {
      message = 'Commence par ajouter ta première tâche.';
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 350,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 75,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucune tâche',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: widget.onAddTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une tâche'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
