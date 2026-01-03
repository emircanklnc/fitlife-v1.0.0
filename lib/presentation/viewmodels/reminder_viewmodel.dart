import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/reminder.dart';
import '../../data/repositories/reminder_repository.dart';

class ReminderViewModel extends ChangeNotifier {
  final ReminderRepository _repository;

  ReminderViewModel(this._repository) {
    loadReminders();
  }

  List<Reminder> _reminders = [];

  bool _isLoading = false;


  List<Reminder> get reminders => _reminders;

  bool get isLoading => _isLoading;


  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await _repository.getAllReminders();
    } catch (e) {
      debugPrint('Hatırlatmalar yüklenemedi: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReminder({required String title}) async {
    try {
      final reminder = Reminder(
        id: const Uuid().v4(),
        title: title,
      );

      final success = await _repository.addReminder(reminder);
      
      if (success) {
        await loadReminders();
      }

      return success;
    } catch (e) {
      debugPrint('Hatırlatma eklenemedi: $e');
      return false;
    }
  }

  Future<bool> deleteReminder(String reminderId) async {
    try {
      final success = await _repository.deleteReminder(reminderId);
      
      if (success) {
        await loadReminders();
      }

      return success;
    } catch (e) {
      debugPrint('Hatırlatma silinemedi: $e');
      return false;
    }
  }

  Future<void> clearState() async {
    _reminders.clear();
    await _repository.clearAllReminders();
    notifyListeners();
  }
}

