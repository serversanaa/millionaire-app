// في أعلى الـ State class أو في ملف utils منفصل
String formatTime12Hour(String time24) {
  try {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];

    final period = hour >= 12 ? 'مساءً' : 'صباحاً';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  } catch (e) {
    return time24;
  }
}
