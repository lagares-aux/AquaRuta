import 'package:intl/intl.dart';

String formatTime(DateTime date) {
  // Formato ejemplo: 10:30 AM
  return DateFormat('hh:mm a').format(date);
}
