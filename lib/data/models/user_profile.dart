
class UserProfile {
  final String id;
  final String name;
  final int? age;
  final double? height;
  final double? weight;
  final String? gender;
  final int dailyCalorieGoal;
  final double? targetWeight;
  final List<WeightEntry> weightHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.dailyCalorieGoal = 2000,
    this.targetWeight,
    required this.weightHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'dailyCalorieGoal': dailyCalorieGoal,
      'targetWeight': targetWeight,
      'weightHistory': weightHistory.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int?,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      gender: json['gender'] as String?,
      dailyCalorieGoal: (json['dailyCalorieGoal'] as int?) ?? 2000,
      targetWeight: json['targetWeight'] != null ? (json['targetWeight'] as num).toDouble() : null,
      weightHistory: (json['weightHistory'] as List?)
          ?.map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    int? dailyCalorieGoal,
    double? targetWeight,
    List<WeightEntry>? weightHistory,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      targetWeight: targetWeight ?? this.targetWeight,
      weightHistory: weightHistory ?? this.weightHistory,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight': weight,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        date: DateTime.parse(json['date'] as String),
        weight: (json['weight'] as num).toDouble(),
      );
}
