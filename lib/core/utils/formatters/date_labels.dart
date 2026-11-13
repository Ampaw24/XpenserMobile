import 'package:intl/intl.dart';

/// "Today", "Yesterday", or a short locale date (e.g. "Nov 13, 2026").
String relativeDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat.yMMMd().format(date);
}

/// "Today, 2:05 PM" style label for a UTC or local timestamp.
String relativeDateTimeLabel(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${relativeDayLabel(local)}, ${DateFormat.jm().format(local)}';
}

/// Compact inclusive range, e.g. "Nov 1 – 30, 2026", "Nov 1, 2026 – Jan 31, 2027".
String dateRangeLabel(DateTime start, DateTime end) {
  if (start.year != end.year) {
    final full = DateFormat.yMMMd();
    return '${full.format(start)} – ${full.format(end)}';
  }
  final year = DateFormat.y().format(end);
  if (start.month == end.month) {
    return '${DateFormat.MMMd().format(start)} – ${DateFormat.d().format(end)}, $year';
  }
  return '${DateFormat.MMMd().format(start)} – ${DateFormat.MMMd().format(end)}, $year';
}
