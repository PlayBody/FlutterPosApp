import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/common/globals.dart' as globals;
import 'package:staff_pos_app/src/model/event_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../apiendpoint.dart';

class ClEvent {
  Future<bool> saveEvents(
      context, eventId, organId, fromTime, toTime, comment, url) async {
    String apiURL = '$apiBase/apievents/saveEvent';
    await Webservice().loadHttp(context, apiURL, {
      'event_id': eventId ?? '',
      'company_id': globals.companyId,
      'organ_id': organId,
      'from_time': fromTime,
      'to_time': toTime,
      'comment': comment,
      'url': url,
      'reg_staff_id': globals.staffId
    });

    return true;
  }

  Future<List<Appointment>> loadEvents(context, dynamic param) async {
    List<Appointment> appointments = [];

    String apiUrl = '$apiBase/apievents/loadEvents';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl,
        {'condition': jsonEncode(param)}).then((value) => results = value);
    for (var item in results['events']) {
      appointments.add(Appointment(
          startTime: DateTime.parse(item['from_time']),
          endTime: DateTime.parse(item['to_time']),
          subject: item['organ_name'],
          color: item['organ_id'].toString() == '0'
              ? Colors.green.withOpacity(0.5)
              : Colors.blue.withOpacity(0.5),
          startTimeZone: '',
          endTimeZone: '',
          notes: item['id'].toString()));
    }

    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));
    return appointments;
  }

  Future<EventModel> loadEventDetail(context, String eventId) async {
    String apiUrl = '$apiBase/apievents/loadEventDetail';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {'event_id': eventId}).then(
        (value) => results = value);

    return EventModel.fromJson(results['event']);
  }

  Future<bool> deleteEvent(context, String eventId) async {
    String apiUrl = '$apiBase/apievents/deleteEvent';
    await Webservice().loadHttp(context, apiUrl, {'event_id': eventId});

    return true;
  }
}
