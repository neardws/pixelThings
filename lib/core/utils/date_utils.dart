import 'package:pixel_things/core/models/app_settings.dart';

class DateFormatUtils {
  static const List<String> weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> weekdaysZh = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static String formatDate(DateTime date, DateFormat format) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    switch (format) {
      case DateFormat.mmdd:
        return '$month/$day';
      case DateFormat.ddmm:
        return '$day/$month';
      case DateFormat.mmddDash:
        return '$month-$day';
      case DateFormat.ddmmDot:
        return '$day.$month';
    }
  }

  static String getWeekdayShort(int weekday, {bool useZh = false}) {
    final index = weekday - 1; // DateTime.weekday is 1-7 (Mon-Sun)
    if (index < 0 || index > 6) return '';
    return useZh ? weekdaysZh[index] : weekdaysEn[index];
  }

  static String formatDateWithWeekday(
    DateTime date,
    DateFormat format, {
    bool showWeekday = true,
    bool useZh = false,
  }) {
    final dateStr = formatDate(date, format);
    if (!showWeekday) return dateStr;
    
    final weekday = getWeekdayShort(date.weekday, useZh: useZh);
    return '$dateStr $weekday';
  }
}
