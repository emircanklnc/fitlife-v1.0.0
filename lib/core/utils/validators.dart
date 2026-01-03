import '../constants/app_strings.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.nameRequired;
    }
    
    if (value.length < 2) {
      return AppStrings.nameTooShort;
    }
    
    return null;
  }

  static String? validateNumber(String? value, {String fieldName = ''}) {
    if (value == null || value.isEmpty) {
      return fieldName.isEmpty ? AppStrings.fieldRequired : '$fieldName ${AppStrings.fieldRequired.toLowerCase()}';
    }
    
    if (double.tryParse(value) == null) {
      return AppStrings.invalidNumber;
    }
    
    return null;
  }

  static String? validatePositiveNumber(String? value, {String fieldName = ''}) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    if (double.parse(value!) <= 0) {
      return '$fieldName ${AppStrings.mustBePositive.toLowerCase()}';
    }
    
    return null;
  }

  static String? validateAge(String? value) {
    final numberError = validatePositiveNumber(value, fieldName: AppStrings.age);
    if (numberError != null) return numberError;
    
    final age = int.parse(value!);
    if (age < 13 || age > 120) {
      return AppStrings.ageInvalid;
    }
    
    return null;
  }

  static String? validateHeight(String? value) {
    final numberError = validatePositiveNumber(value, fieldName: AppStrings.height);
    if (numberError != null) return numberError;
    
    final height = double.parse(value!);
    if (height < 100 || height > 250) {
      return AppStrings.heightInvalid;
    }
    
    return null;
  }

  static String? validateWeight(String? value) {
    final numberError = validatePositiveNumber(value, fieldName: AppStrings.weight);
    if (numberError != null) return numberError;
    
    final weight = double.parse(value!);
    if (weight < 30 || weight > 300) {
      return AppStrings.weightInvalid;
    }
    
    return null;
  }

  static String? validateRequired(String? value, {String fieldName = ''}) {
    if (value == null || value.isEmpty) {
      return fieldName.isEmpty ? AppStrings.fieldRequired : '$fieldName ${AppStrings.fieldRequired.toLowerCase()}';
    }
    return null;
  }
}
