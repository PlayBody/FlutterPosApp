import 'package:staff_pos_app/src/http/webservice.dart';

import '../apiendpoint.dart';

class ClGroup {
  Future<bool> deleteGroup(context, String groupId) async {
    String apiUrl = '$apiBase/apigroups/deleteGroup';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiUrl, {'group_id': groupId}).then((v) => {results = v});

    return results['isDelete'];
  }
}
