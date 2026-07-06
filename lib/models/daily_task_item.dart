class DailyTaskItem {
  final String text;
  final bool done;

  const DailyTaskItem({this.text = '', this.done = false});

  factory DailyTaskItem.fromJson(Map<String, dynamic> json) {
    return DailyTaskItem(
      text: (json['text'] as String?) ?? '',
      done: (json['done'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'done': done};
  }
}
