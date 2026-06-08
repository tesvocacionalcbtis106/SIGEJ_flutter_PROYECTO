import 'package:intl/intl.dart';

class AppDateUtils {
  static String format(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
