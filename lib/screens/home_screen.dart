import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/study_task.dart';
import '../providers/task_provider.dart';
import '../utils/priority_helper.dart';
import '../widgets/task_card.dart';
import 'tasks_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> pageTitles = [
    'StudyFlow',
    'Mes tâches',
    'Planning',
    'Statistiques',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[selectedIndex],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: selectedIndex == 0
            ? [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: selectedIndex == 0
          ? buildHomePage()
          : selectedIndex == 1
              ? TasksScreen(
                  onAddTask: () => openTaskForm(),
                  onEditTask: (task) => openTaskForm(task: task),
                )
              : selectedIndex == 2
                  ? buildPlannerPage()
                  : buildStatisticsPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tâches',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planning',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    final provider = context.watch<TaskProvider>();

    final tasks = provider.tasks;

    final upcomingTasks = tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    final displayedTasks = upcomingTasks.take(3).toList();

    return RefreshIndicator(
      onRefresh: provider.loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bonjour 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Organisons tes révisions.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 25),
            buildProgressCard(provider),
            const SizedBox(height: 25),
            const Text(
              'Vue d’ensemble',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: buildStatCard(
                    title: 'Total',
                    value: provider.totalTasks.toString(),
                    icon: Icons.assignment_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildStatCard(
                    title: 'Terminées',
                    value: provider.completedTasks.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildStatCard(
                    title: 'En cours',
                    value: provider.pendingTasks.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildStatCard(
                    title: 'En retard',
                    value: provider.overdueTasks.toString(),
                    icon: Icons.warning_amber,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Mes tâches à venir',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (provider.isLoading && tasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (displayedTasks.isEmpty)
              buildEmptyTasksCard()
            else
              ...displayedTasks.map((task) {
                return TaskCard(
                  task: task,
                  onToggle: () {
                    context.read<TaskProvider>().toggleTaskCompletion(task);
                  },
                  onEdit: () {
                    openTaskForm(task: task);
                  },
                  onDelete: () {
                    deleteTask(task);
                  },
                );
              }),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => openTaskForm(),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une tâche'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3576BC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildProgressCard(TaskProvider provider) {
    final percentage = (provider.progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3576BC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ma progression',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFBBD6F2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${provider.completedTasks} tâche(s) terminée(s) '
            'sur ${provider.totalTasks}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyTasksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 50,
            color: Color(0xFF3576BC),
          ),
          SizedBox(height: 12),
          Text(
            'Aucune tâche pour le moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tes prochaines révisions apparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openTaskForm({StudyTask? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
  }

  Future<void> deleteTask(StudyTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la tâche ?'),
          content: Text(
            'Voulez-vous supprimer "${task.title}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<TaskProvider>().deleteTask(task.id!);
    }
  }

  Widget buildPlannerPage() {
    final provider = context.watch<TaskProvider>();

    final tasks = provider.tasks.where((task) => !task.isCompleted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final tomorrow = today.add(const Duration(days: 1));

    final groups = <String, List<StudyTask>>{
      'En retard': [],
      'Aujourd’hui': [],
      'Demain': [],
      'Cette semaine': [],
      'Plus tard': [],
    };

    for (final task in tasks) {
      final deadline = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );

      final difference = deadline.difference(today).inDays;

      if (difference < 0) {
        groups['En retard']!.add(task);
      } else if (difference == 0) {
        groups['Aujourd’hui']!.add(task);
      } else if (difference == 1) {
        groups['Demain']!.add(task);
      } else if (difference <= 6) {
        groups['Cette semaine']!.add(task);
      } else {
        groups['Plus tard']!.add(task);
      }
    }

    if (provider.isLoading && tasks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.loadTasks,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 75,
                        color: Colors.blue.shade300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ton planning est vide',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ajoute des tâches pour organiser '
                        'tes prochaines révisions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => openTaskForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une tâche'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadTasks,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF3576BC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_note,
                  color: Colors.white,
                  size: 35,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mes prochaines révisions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${tasks.length} tâche(s) restante(s)',
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
          const SizedBox(height: 25),
          ...groups.entries.map((entry) {
            if (entry.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return buildPlannerGroup(
              title: entry.key,
              tasks: entry.value,
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildPlannerGroup({
    required String title,
    required List<StudyTask> tasks,
  }) {
    Color groupColor;

    IconData groupIcon;

    switch (title) {
      case 'En retard':
        groupColor = Colors.red;
        groupIcon = Icons.warning_amber_rounded;
        break;

      case 'Aujourd’hui':
        groupColor = Colors.blue;
        groupIcon = Icons.today;
        break;

      case 'Demain':
        groupColor = Colors.orange;
        groupIcon = Icons.event;
        break;

      case 'Cette semaine':
        groupColor = Colors.purple;
        groupIcon = Icons.date_range;
        break;

      default:
        groupColor = Colors.teal;
        groupIcon = Icons.calendar_month;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                groupIcon,
                color: groupColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: groupColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tasks.length.toString(),
                  style: TextStyle(
                    color: groupColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final priority = PriorityHelper.calculatePriority(task);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor:
                      PriorityHelper.getColor(priority).withValues(alpha: 0.12),
                  child: Icon(
                    PriorityHelper.getIcon(priority),
                    color: PriorityHelper.getColor(priority),
                  ),
                ),
                title: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '${task.subject}\n'
                    '${task.deadline.day.toString().padLeft(2, '0')}/'
                    '${task.deadline.month.toString().padLeft(2, '0')}/'
                    '${task.deadline.year}',
                  ),
                ),
                trailing: SizedBox(
                  width: 75,
                  child: Text(
                    PriorityHelper.getLabel(priority),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: PriorityHelper.getColor(priority),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  openTaskForm(task: task);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildStatisticsPage() {
    final provider = context.watch<TaskProvider>();

    final total = provider.totalTasks;
    final completed = provider.completedTasks;
    final pending = provider.pendingTasks;
    final overdue = provider.overdueTasks;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mon bilan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suivi de tes révisions et de tes objectifs.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: buildStatCard(
                  title: 'Total',
                  value: total.toString(),
                  icon: Icons.assignment_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildStatCard(
                  title: 'Terminées',
                  value: completed.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildStatCard(
                  title: 'En cours',
                  value: pending.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildStatCard(
                  title: 'En retard',
                  value: overdue.toString(),
                  icon: Icons.warning_amber,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progression globale',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${(provider.progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3576BC),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: provider.progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF3576BC),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '$completed tâche(s) terminée(s) sur $total',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Répartition des tâches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (total == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Ajoute des tâches pour voir '
                            'tes statistiques.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 45,
                            sections: [
                              if (completed > 0)
                                PieChartSectionData(
                                  value: completed.toDouble(),
                                  color: Colors.green,
                                  title:
                                      '${(completed / total * 100).round()}%',
                                  radius: 70,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              if (pending > 0)
                                PieChartSectionData(
                                  value: pending.toDouble(),
                                  color: Colors.orange,
                                  title: '${(pending / total * 100).round()}%',
                                  radius: 70,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildLegendItem(
                        color: Colors.green,
                        label: 'Terminées ($completed)',
                      ),
                      const SizedBox(height: 10),
                      buildLegendItem(
                        color: Colors.orange,
                        label: 'En cours ($pending)',
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
