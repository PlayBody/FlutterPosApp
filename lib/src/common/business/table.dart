// import 'dart:convert';

// import 'package:staff_pos_app/src/http/webservice.dart';
// import '../apiendpoint.dart';

// class ClTable {
//   Future<bool> saveRejectTable(context, organId) async {
//     String apiUrl = apiBase + '/apitables/saveRejectTable';

//     Map<dynamic, dynamic> results = {};
//     await Webservice().loadHttp(context, apiUrl, {
//       'organ_id': organId,
//     }).then((v) => {results = v});

//     if (!results['isSave']) {
//       return false;
//     }

//     return true;
//   }

//   Future<bool> updateTableData(context, updateData) async {
//     String apiUrl = apiBase + '/apitables/updateTableData';
//     Map<dynamic, dynamic> results = {};
//     await Webservice().loadHttp(context, apiUrl, {
//       'update_data': jsonEncode(updateData),
//     }).then((v) => {results = v});

//     return results['isUpdate'];
//   }
// }
