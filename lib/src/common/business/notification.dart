import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:staff_pos_app/src/common/business/message.dart';
import 'package:staff_pos_app/src/http/webservice.dart';

import '../apiendpoint.dart';

class ClNotification {
  Future<void> sendNotification(
    context,
    type,
    title,
    content,
    senderId,
    senderType,
    receiverIds,
    receiverType,
  ) async {
    // Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apinotifications/sendNotifications';
    await Webservice().loadHttp(context, apiUrl, {
      'type': type,
      'title': title,
      'content': content,
      'sender_id': senderId,
      'sender_type': senderType,
      'receiver_ids': receiverIds,
      'receiver_type': receiverType,
    });

    // return results['isSend'];
  }

  Future<String> getBageCount(context, staffId) async {
    String apiUrl = '$apiBase/apimessages/getStaffUnreadCount';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'receiver_id': staffId,
      'receiver_type': '1',
    }).then((value) => results = value);

    return results['count'].toString();
  }

  Future<void> removeBadge(context, receiverId, notificationType) async {
    String apiUrl = '$apiBase/apinotifications/removeBadge';

    String badgeCount = '0';

    if (notificationType == '1') {
      badgeCount = await ClMessage().loadUnreadMessageCount(context);
    }

    await Webservice().loadHttp(context, apiUrl, {
      'receiver_id': receiverId,
      'receiver_type': '1',
      'notification_type': notificationType,
      'badge_count': badgeCount
    });

    String badge = await getBageCount(context, receiverId);

    FlutterAppBadger.updateBadgeCount(int.parse(badge == 'null' ? '0' : badge));
  }

  Future<int> getBageCountDetail(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiGetBadgeCount, param)
        .then((value) => results = value);

    return int.parse(results['count'].toString());
  }

  Future<List<String>> getUserIds(context, param) async {
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiGetBadgeCount, param)
        .then((value) => results = value);

    List<String> temp = [];
    for(var el in results['userIds']) {
      temp.add(el.toString());
    }
    return temp;
  }
}
