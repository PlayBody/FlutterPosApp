// import 'dart:convert';

// import 'package:staff_pos_app/src/common/apiendpoint.dart';
// import 'package:staff_pos_app/src/common/dialogs.dart';
// import 'package:staff_pos_app/src/http/webservice.dart';
// import 'package:staff_pos_app/src/model/reservemodel.dart';

// class ClReserve {
//   Future<List<ReserveModel>> loadReserves(context, param) async {
//     Map<dynamic, dynamic> results = {};
//     await Webservice().loadHttp(context, apiLoadReserves, {
//       'condition': jsonEncode(param),
//     }).then((v) => {results = v});

//     List<ReserveModel> reserves = [];
//     if (results['isLoad']) {
//       for (var item in results['reserves']) {
//         reserves.add(ReserveModel.fromJson(item));
//       }
//     }
//     return reserves;
//   }

//   Future<bool> applyReserve(context, reserveId) async {
//     bool conf = await Dialogs().confirmDialog(context, '予約を承認しますか？');
//     if (!conf) return false;
//     await Webservice().loadHttp(context, apiApplyReserveDataUrl, {
//       'reserve_id': reserveId,
//     });

//     return true;
//   }

//   Future<bool> rejectReserve(context, reserveId) async {
//     bool conf = await Dialogs().confirmDialog(context, '予約を拒否しますか？');
//     if (!conf) return false;
//     await Webservice().loadHttp(context, apiRejectReserveDataUrl, {
//       'reserve_id': reserveId,
//     });

//     return true;
//   }
// }
