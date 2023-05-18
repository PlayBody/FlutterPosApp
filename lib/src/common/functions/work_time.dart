// class WorkTime {
//   DateTime start;
//   DateTime end;
//   WorkTime(this.start, this.end);
// }

// List<WorkTime> assignWork(
//     List<WorkTime> workTime, int numPeople, WorkTime requiredTime) {
//   // workTime: [WorkTime(start1, end1), WorkTime(start2, end2), ...]
//   // numPeople: 요구하는 인원 수
//   // requiredTime: 요구하는 시간 구역을 나타내는 WorkTime 객체
//   List<WorkTime> avaliableTime = workTime
//       .where((wt) =>
//           requiredTime.start.isBefore(wt.end) &&
//           requiredTime.end.isAfter(wt.start))
//       .toList();
//   if (avaliableTime.isNotEmpty ||
//       avaliableTime.fold<int>(
//               0, (a, b) => a + b.end.difference(b.start).inDays) <
//           numPeople) {
//     return [];
//   }
//   // 일할 수 있는 시간이 가장 긴 순서대로 정렬
//   avaliableTime.sort((a, b) => b.end
//       .difference(b.start)
//       .inDays
//       .compareTo(a.end.difference(a.start).inDays));
//   List<WorkTime> result = [];
//   for (int i = 0; i < numPeople; i++) {
//     WorkTime wt = avaliableTime[i % avaliableTime.length];
//     int days = wt.end.difference(wt.start).inDays;
//     DateTime start =
//         wt.start.add(Duration(days: (i ~/ avaliableTime.length) * days));
//     DateTime end = start.add(Duration(days: days));
//     result.add(WorkTime(start, end));
//   }
//   return result;
// }

// // 예시
// void main() {
//   List<WorkTime> workTime = [
//     WorkTime(DateTime(2022, 10, 1), DateTime(2022, 10, 5)),
//     WorkTime(DateTime(2022, 11, 6), DateTime(2022, 11, 13)),
//     WorkTime(DateTime(2022, 10, 15), DateTime(2022, 10, 20)),
//     WorkTime(DateTime(2022, 11, 15), DateTime(2022, 11, 20)),
//   ];
//   int numPeople = 1;
//   WorkTime requiredTime =
//       WorkTime(DateTime(2022, 10, 2), DateTime(2022, 10, 14));
//   List<WorkTime> result = assignWork(workTime, numPeople, requiredTime);
//   if (result.isEmpty) {
//     print("일을 할 수 있는 인원 수가 부족합니다.");
//   } else {
//     for (var r in result) {
//       print("${r.start} ~ ${r.end}");
//     }
//   }
// }
