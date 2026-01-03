
class Exercise {
  final String id;
  final DateTime date;
  final String type;
  final String name;
  final int duration;
  final int caloriesBurned;

  Exercise({
    required this.id,
    required this.date,
    required this.type,
    required this.name,
    required this.duration,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'name': name,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      name: json['name'] as String,
      duration: json['duration'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
    );
  }

  factory Exercise.fromApiJson(Map<String, dynamic> json) {
    final dateStr = json['exercise_date'] as String;
    final dateParts = dateStr.split('-');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    return Exercise(
      id: json['id'].toString(),
      date: date,
      type: json['exercise_type'] as String,
      name: json['exercise_name'] as String,
      duration: json['duration_minutes'] as int,
      caloriesBurned: json['calories_burned'] as int,
    );
  }

  Exercise copyWith({
    String? type,
    String? name,
    int? duration,
    int? caloriesBurned,
  }) {
    return Exercise(
      id: id,
      date: date,
      type: type ?? this.type,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
}
