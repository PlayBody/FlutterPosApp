// import 'menumodel.dart';

// class ReserveModel {
//   final String reserveId;
//   final String organId;
//   final String organName;
//   final String userId;
//   final String? staffId;
//   final String staffName;
//   final String reserveTime;
//   final String reserveExitTime;
//   final String reserveStatus;
//   final String updateDate;
//   final String sumAmount;
//   final List<MenuModel> menus;
//   final String? userFirstName;
//   final String? userLastName;

//   const ReserveModel({
//     required this.reserveId,
//     required this.organId,
//     required this.organName,
//     required this.userId,
//     this.staffId,
//     required this.staffName,
//     required this.reserveTime,
//     required this.reserveExitTime,
//     required this.reserveStatus,
//     required this.updateDate,
//     required this.sumAmount,
//     required this.menus,
//     this.userFirstName,
//     this.userLastName,
//   });

//   factory ReserveModel.fromJson(Map<String, dynamic> json) {
//     var sum = '0';
//     List<MenuModel> menuList = [];
//     if (json['menus'] != null) {
//       for (var item in json['menus']) {
//         sum = (int.parse(sum) +
//                 int.parse(
//                     item['menu_price'] == null ? '0' : item['menu_price']))
//             .toString();
//         menuList.add(MenuModel.fromJson(item));
//       }
//     }

//     return ReserveModel(
//       reserveId: json['reserve_id'],
//       organId: json['organ_id'],
//       organName: json['organ_name'],
//       userId: json['user_id'],
//       staffId: json['staff_id'],
//       staffName: json['staff_name'].toString(),
//       reserveTime: json['reserve_time'],
//       reserveExitTime: json['reserve_exit_time'],
//       reserveStatus: json['reserve_status'] == null
//           ? ''
//           : json['reserve_status'].toString(),
//       updateDate: json['update_date'],
//       sumAmount: sum,
//       menus: menuList,
//       userFirstName: json['user_first_name'],
//       userLastName: json['user_last_name'],
//     );
//   }
// }
