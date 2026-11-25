class StudyTask {
  final int? id;
  final String title;
  final String subject;
  final String description;
  final DateTime deadline;
  final bool isCompleted;

  StudyTask({
    this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    return StudyTask(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  StudyTask copyWith({
    int? id,
    String? title,
    String? subject,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
