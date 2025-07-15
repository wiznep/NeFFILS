import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class Formatter {
  static final dateFormatter = DateFormat('dd MMMM, yyyy');
  static final dateFormatter2 = DateFormat('yyyy-MM-dd');
  static final timeFormatter = DateFormat.Hms();
}

class NepaliDateFormatter {
  static final dateFormatter = NepaliDateFormat.yMd();
  static final textDateFormatter = NepaliDateFormat.yMMMMd();
  static final dayDateFormatter = NepaliDateFormat.yMMMMEEEEd();
}

// TimeOfDay stringToTimeOfDay(String tod) {
//   final format = DateFormat.jm(); //"6:00 AM"
//   return TimeOfDay.fromDateTime(format.parse(tod));
// }
