import 'package:intl/intl.dart';

class DateTimes {
  String convertTimeFromDouble(v) {
    int hInt = v.toInt();
    int mInt = ((v - v.toInt()) * 60).toInt();
    String hour = hInt < 10 ? '0$hInt' : hInt.toString();
    String min = mInt < 10 ? '0$mInt' : mInt.toString();
    return '$hour:$min:00';
  }

  String convertTimeFromDateTime(v) {
    String hour = v.hour < 10 ? '0${v.hour}' : v.hour.toString();
    String min = v.minute < 10 ? '0${v.minute}' : v.minute.toString();
    return '$hour:$min:00';
  }

  String convertTimeFromDateTimeAddHour(v, h) {
    return "${((v.hour + h) < 10 ? '0${(v.hour + h).toString()}' : (v.hour + h).toString())}:${(v.minute < 10 ? '0${v.minute}' : v.minute.toString())}:00";
  }

  String convertTimeFromString(String v) {
    return DateFormat('HH:mm:ss').format(DateTime.parse(v));
  }

  String convertJPYMFromDateTime(DateTime v) {
    return '${v.year}年${v.month}月';
  }

  String convertJPYMDFromDateTime(DateTime v, {bool isFull = false}) {
    String year = isFull ? v.year.toString() : (v.year - 2000).toString();
    return '$year年${v.month.toString()}月${v.day.toString()}日';
  }

  String convertJPYMFromString(String s) {
    DateTime v = DateTime.parse(s);
    return '${v.year}年${v.month}月';
  }
}
