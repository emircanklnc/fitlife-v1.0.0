import '../models/reminder.dart';
import '../services/local_storage_service.dart';

class ReminderRepository {
  final LocalStorageService _storageService;
  
  static const String _remindersKey = 'reminders';

  ReminderRepository(this._storageService);

  Future<List<Reminder>> getAllReminders() async {
    return _getRemindersFromLocal();
  }

  Future<bool> addReminder(Reminder reminder) async {
    try {
      final reminders = _getRemindersFromLocal();
      reminders.add(reminder);
      return await _saveRemindersToLocal(reminders);
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReminder(String reminderId) async {
    try {
      final reminders = _getRemindersFromLocal();
      reminders.removeWhere((r) => r.id == reminderId);
      return await _saveRemindersToLocal(reminders);
    } catch (e) {
      return false;
    }
  }


  List<Reminder> _getRemindersFromLocal() {
    final jsonList = _storageService.getJsonList(_remindersKey);
    if (jsonList == null) return [];
    
    return jsonList
        .map((json) => Reminder.fromJson(json))
        .toList();
  }

  Future<bool> _saveRemindersToLocal(List<Reminder> reminders) async {
    final jsonList = reminders.map((r) => r.toJson()).toList();
    return await _storageService.saveJsonList(_remindersKey, jsonList);
  }

  Future<bool> clearAllReminders() async {
    try {
      return await _storageService.remove(_remindersKey);
    } catch (e) {
      return false;
    }
  }
}
