
class Reminder {
  final String id;
  final String title;

  Reminder({
    required this.id,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  factory Reminder.fromApiJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'].toString(),
      title: json['title'] as String,
    );
  }
}

