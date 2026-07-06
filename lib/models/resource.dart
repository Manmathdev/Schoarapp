class Resource {
  final int id;
  String title;
  String url;
  String subject;
  String type;

  Resource({
    required this.id,
    required this.title,
    required this.url,
    required this.subject,
    required this.type,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      subject: json['subject'] as String,
      type: (json['type'] as String?) ?? 'Website',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'subject': subject,
      'type': type,
    };
  }
}
