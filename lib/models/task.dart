class Task {
  final int id;
  String subject;
  String title;
  String notes;
  String status;
  String color;

  Task({
    required this.id,
    required this.subject,
    required this.title,
    this.notes = '',
    this.status = 'Not Started',
    this.color = '#9c9490',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      subject: json['subject'] as String,
      title: json['title'] as String,
      notes: (json['notes'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'Not Started',
      color: (json['color'] as String?) ?? '#9c9490',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'notes': notes,
      'status': status,
      'color': color,
    };
  }
}
