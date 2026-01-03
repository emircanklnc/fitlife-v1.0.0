
class FoodLog {
  final String id;
  final DateTime date;
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodLog({
    required this.id,
    required this.date,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      foodName: json['foodName'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  factory FoodLog.fromApiJson(Map<String, dynamic> json) {
    final dateStr = json['meal_date'] as String;
    final dateParts = dateStr.split('-');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    return FoodLog(
      id: json['id'].toString(),
      date: date,
      foodName: json['food_name'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  double get totalMacros => protein + carbs + fat;

  double get proteinPercentage => totalMacros > 0 ? protein / totalMacros : 0;

  double get carbsPercentage => totalMacros > 0 ? carbs / totalMacros : 0;

  double get fatPercentage => totalMacros > 0 ? fat / totalMacros : 0;
}
