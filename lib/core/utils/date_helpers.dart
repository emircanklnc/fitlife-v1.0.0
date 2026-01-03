import 'package:intl/intl.dart';

class DateHelpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy', 'tr').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'tr').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'tr').format(date);
  }

  static String formatDateChart(DateTime date) {
    return DateFormat('dd MMM', 'tr').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}g önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}s önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}d önce';
    } else {
      return 'Az önce';
    }
  }
}
