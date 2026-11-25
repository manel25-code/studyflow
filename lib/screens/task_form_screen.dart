import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final StudyTask? task;

  const TaskFormScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;

  bool _isSaving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );

    _subjectController = TextEditingController(
      text: widget.task?.subject ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    _selectedDate = widget.task?.deadline ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Choisir la date limite',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<TaskProvider>();

    final newTask = StudyTask(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _selectedDate,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    try {
      if (isEditing) {
        await provider.updateTask(newTask);
      } else {
        await provider.addTask(newTask);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Tâche modifiée avec succès !'
                : 'Tâche ajoutée avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue. Réessayez.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la tâche' : 'Nouvelle tâche',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Organise tes révisions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Remplis les informations de ta tâche.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Titre *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: 'Ex : Réviser le chapitre 3',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est obligatoire.';
                  }

                  if (value.trim().length < 3) {
                    return 'Le titre doit contenir au moins 3 caractères.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text(
                'Matière *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                maxLength: 40,
                decoration: InputDecoration(
                  hintText: 'Ex : Machine Learning',
                  prefixIcon: const Icon(Icons.book_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La matière est obligatoire.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 250,
                decoration: InputDecoration(
                  hintText: 'Détails de la tâche...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Date limite *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF3576BC),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3576BC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          isEditing
                              ? 'Enregistrer les modifications'
                              : 'Ajouter la tâche',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
