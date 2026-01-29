import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
  return DateFormat.jm().format(dateTime);
}
