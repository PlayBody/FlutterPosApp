class DateInterval {
  final DateTime from;
  DateTime to;

  DateInterval({required this.from, required this.to}) {
    if (from.compareTo(to) > 0) {
      to = from;
    }
  }

  Duration getDuration() {
    return to.difference(from);
  }
}

class DateIntervalUtil {
  static List<DateInterval> sortIntervals(List<DateInterval> list) {
    list.sort((a, b) {
      if (a.from.compareTo(b.from) == 0) {
        return a.to.compareTo(b.to);
      }
      return a.from.compareTo(b.from);
    });
    return list;
  }

  static List<DateInterval> optimizeIntervals(List<DateInterval> list) {
    list = sortIntervals(list);
    if (list.isEmpty || list.length == 1) {
      return list;
    }
    DateTime from = list[0].from;
    DateTime to = list[0].to;
    List<DateInterval> outs = List.empty(growable: true);
    for (int i = 1; i < list.length; i++) {
      if (list[i].from.compareTo(to) >= 0) {
        outs.add(DateInterval(from: from, to: to));
        from = list[i].from;
        to = list[i].to;
      } else {
        to = list[i].to;
      }
    }

    outs.add(DateInterval(from: from, to: to));
    return outs;
  }

  static int getNoOverlapMinutes(List<DateInterval> list) {
    List<DateInterval> temps = optimizeIntervals(list);
    int d = 0;
    for (DateInterval item in temps) {
      d += item.getDuration().inMinutes;
    }
    return d;
  }

  static int getTotalMinutes(List<DateInterval> list) {
    int d = 0;
    for (DateInterval item in list) {
      d += item.getDuration().inMinutes;
    }
    return d;
  }
}
