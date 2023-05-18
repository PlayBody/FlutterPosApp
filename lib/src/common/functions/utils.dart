// class WorkTime {
//   static Map<String, int> hoursOnWeek = {};

//   DateTime start;
//   DateTime end;

//   DateTime oldStart = DateTime(2022);
//   DateTime oldEnd = DateTime(2022);

//   dynamic meta;

//   static void cleanHoursOnWeek() {
//     hoursOnWeek = {};
//   }

//   static void updateHoursOnWeek(String? key, int? duration) {
//     hoursOnWeek[key ?? "_"] = duration ?? 0;
//   }

//   factory WorkTime.fromWorkTime(WorkTime other) {
//     return WorkTime(other.start, other.end)
//       ..meta = other.meta
//       ..oldStart = other.oldStart
//       ..oldEnd = other.oldEnd;
//   }

//   bool isChanged() {
//     return start.compareTo(oldStart) < 0 || end.compareTo(oldEnd) > 0;
//   }

//   // like left join
//   WorkTime getFixTime(WorkTime other) {
//     int compStart = start.compareTo(other.start);
//     int compEnd = end.compareTo(other.end);
//     DateTime st = compStart < 0 ? other.start : start;
//     DateTime en = compEnd < 0 ? end : other.end;
//     return WorkTime(st, en)
//       ..meta = other.meta
//       ..oldStart = other.oldStart
//       ..oldEnd = other.oldEnd;
//   }

//   // like other - this
//   // must this.duration() > other.duration();
//   WorkTime getOutTime(WorkTime other) {
//     int comp1 = start.compareTo(other.end);
//     int comp2 = end.compareTo(other.start);
//     if (comp1 >= 0 || comp2 <= 0) {
//       return WorkTime.fromWorkTime(
//           other); //.start, other.end)..meta = other.meta;
//     } else {
//       int compStart = start.compareTo(other.start);
//       if (compStart < 0) {
//         return WorkTime(end, other.end)
//           ..meta = other.meta
//           ..oldStart = other.oldStart
//           ..oldEnd = other.oldEnd;
//       } else {
//         return WorkTime(other.start, start)
//           ..meta = other.meta
//           ..oldStart = other.oldStart
//           ..oldEnd = other.oldEnd;
//       }
//     }
//   }

//   WorkTime(this.start, this.end) {
//     meta = null;
//     oldStart = start;
//     oldEnd = end;
//   }

//   Duration getDuration() {
//     return end.difference(start);
//   }

//   bool isValid() {
//     return start.compareTo(end) < 0;
//   }

//   int compareToByTime(WorkTime other) {
//     int compStart = start.compareTo(other.start);
//     int compEnd = end.compareTo(other.end);
//     if (compStart == 0) {
//       if (compEnd == 0) {
//         return 0;
//       } else {
//         return compEnd;
//       }
//     } else {
//       return compStart;
//     }
//   }

//   int getDurationByMinutes() {
//     return end.difference(start).inMinutes;
//   }

//   int getHoursOnWeek() {
//     return hoursOnWeek[meta.staffId] ?? 0;
//   }

//   int compareToByHoursOnWeek(WorkTime other) {
//     return -getHoursOnWeek().compareTo(other.getHoursOnWeek());
//   }

//   int compareToByDuration(WorkTime other) {
//     return getDurationByMinutes().compareTo(other.getDurationByMinutes());
//   }
// }

// class WorkTimeUtil {
//   static List<WorkTime> sortWorkTimesByTime(List<WorkTime> works) {
//     works.sort((a, b) {
//       if (a.start.compareTo(b.start) == 0) {
//         return a.end.compareTo(b.end);
//       }
//       return a.start.compareTo(b.start);
//     });
//     return works;
//   }

//   static List<WorkTime> optimizeWorkTimes(List<WorkTime> works) {
//     works = sortWorkTimesByTime(works);
//     if (works.isEmpty || works.length == 1) {
//       return works;
//     }
//     DateTime start = works[0].start;
//     DateTime end = works[0].end;
//     List<WorkTime> outs = List.empty(growable: true);
//     for (int i = 1; i < works.length; i++) {
//       if (works[i].start.compareTo(end) >= 0) {
//         outs.add(WorkTime(start, end));
//         start = works[i].start;
//         end = works[i].end;
//       } else {
//         end = works[i].end;
//       }
//     }

//     outs.add(WorkTime(start, end));
//     return outs;
//   }

//   static int getNoOverlapMinutes(List<WorkTime> works) {
//     List<WorkTime> temps = optimizeWorkTimes(works);
//     int d = 0;
//     for (WorkTime item in temps) {
//       d += item.getDuration().inMinutes;
//     }
//     return d;
//   }

//   static int getTotalMinutes(List<WorkTime> works) {
//     int d = 0;
//     for (WorkTime item in works) {
//       d += item.getDuration().inMinutes;
//     }
//     return d;
//   }

//   static List<dynamic> assignWorkRange(
//       List<WorkTime> workers, WorkTime requiredTime, int requiredCount) {
//     if (workers.isEmpty) {
//       return [[], 0];
//     }
//     List<WorkTime> avWorks = [];
//     for (var worker in workers) {
//       if (requiredTime.start.isBefore(worker.end) &&
//           requiredTime.end.isAfter(worker.start)) {
//         avWorks.add(worker);
//       }
//     }
//     if (avWorks.isEmpty) {
//       int m = 0;
//       WorkTime selected = workers[0];
//       for (WorkTime item in workers) {
//         if (item.getHoursOnWeek() > m) {
//           m = item.getHoursOnWeek();
//           selected = item;
//         }
//       }
//       selected.start = requiredTime.start;
//       selected.end = requiredTime.end;
//       return [
//         [selected],
//         1
//       ];
//     } else {
//       avWorks.sort((a, b) => a.compareToByHoursOnWeek(b));

//       for (int i = 0; i < avWorks.length; i++) {
//         if (avWorks[i].isValid()) {
//           for (int j = i + 1; j < avWorks.length; j++) {
//             if (avWorks[j].isValid()) {
//               avWorks[j] = avWorks[i].getOutTime(avWorks[j]);
//             }
//           }
//         }
//       }
//       List<WorkTime> finals =
//           avWorks.where((element) => element.isValid()).toList(growable: true);
//       finals.sort((a, b) => a.compareToByTime(b));

//       List<int> flags = [];

//       for (int j = 1; j < finals.length; j++) {
//         int i = j - 1;
//         if (finals[i].end.compareTo(finals[j].start) < 0) {
//           flags.add(finals[i].compareToByHoursOnWeek(finals[j]) > 0 ? 1 : -1);
//         } else {
//           flags.add(0);
//         }
//       }
//       for (int j = 1; j < finals.length; j++) {
//         int i = j - 1;
//         if (flags[i] > 0) {
//           finals[j].start = finals[i].end;
//         } else if (flags[i] < 0) {
//           finals[i].end = finals[j].start;
//         }
//       }
//       finals[0].start = requiredTime.start;
//       finals[finals.length - 1].end = requiredTime.end;
//       return [finals, 1];
//     }
//   }
// }
