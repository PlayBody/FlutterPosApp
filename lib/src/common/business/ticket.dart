import 'dart:io';

import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/model/ticket_reset_push_setting_model.dart';
import 'package:staff_pos_app/src/model/ticketmastermodel.dart';
import 'package:staff_pos_app/src/model/ticketmodel.dart';
import 'package:staff_pos_app/src/model/userticketmodel.dart';

import '../globals.dart' as globals;
import '../apiendpoint.dart';

class ClTicket {
  Future<List<TicketMasterModel>> loadMasterTicket(context, companyId) async {
    String apiUrl = '$apiBase/apitickets/loadMasterTicket';

    List<TicketMasterModel> ticketMaster = [];
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(
        context, apiUrl, {'company_id': companyId}).then((v) => {results = v});

    for (var item in results['ticket_master']) {
      ticketMaster.add(TicketMasterModel.fromJson(item));
    }

    return ticketMaster;
  }

  Future<List<TicketMasterModel>> loadMasterTicketById(context, id) async {
    String apiUrl = '$apiBase/apitickets/loadMasterTicket';

    List<TicketMasterModel> ticketMaster = [];
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiUrl, {'id': id}).then((v) => {results = v});

    for (var item in results['ticket_master']) {
      ticketMaster.add(TicketMasterModel.fromJson(item));
    }

    return ticketMaster;
  }

  Future<List<TicketModel>> loadTicketList(
    context,
  ) async {
    String apiUrl = '$apiBase/apitickets/loadTicketList';

    List<TicketModel> tickets = [];
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'company_id': globals.companyId,
    }).then((v) => {results = v});

    if (results['isLoad']) {
      for (var item in results['tickets']) {
        tickets.add(TicketModel.fromJson(item));
      }
    } else {
      return [];
    }

    return tickets;
  }

  Future<TicketModel?> loadTicket(context, id) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apitickets/loadTicket';
    await Webservice()
        .loadHttp(context, apiUrl, {'id': id}).then((v) => results = v);
    if (results['isLoad']) {
      return TicketModel.fromJson(results['ticket']);
    } else {
      return null;
    }
  }

  Future<String> uploadTicketImage(context, File uploadFile) async {
    String apiUrl = '$apiBase/apitickets/uploadPhoto';
    String dateFileName = DateTime.now()
        .toString()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll(' ', '');
    String imagename = 'tickets-$dateFileName.jpg';
    await Webservice()
        .callHttpMultiPart('picture', apiUrl, uploadFile.path, imagename);
    return imagename;
  }

  Future<bool> saveTicket(context, param) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apitickets/saveTicket';

    await Webservice()
        .loadHttp(context, apiUrl, param)
        .then((v) => results = v);

    return results['isSave'];
  }

  Future<bool> deleteTicket(context, ticketId) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apitickets/deleteTicket';

    await Webservice().loadHttp(
        context, apiUrl, {'ticket_id': ticketId}).then((v) => results = v);

    return results['isDelete'];
  }

  Future<List<UserTicketModel>> loadUserTickets(
      context, userId, companyId) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apitickets/loadUserTickets';

    await Webservice().loadHttp(context, apiUrl, {
      'company_id': companyId != '' ? companyId : globals.companyId,
      'user_id': userId
    }).then((v) => results = v);
    List<UserTicketModel> tickets = [];
    for (var item in results['tickets']) {
      tickets.add(UserTicketModel.fromJson(item));
    }

    return tickets;
  }

  Future<List<TicketResetPushSettingModel>> loadResetPushSettings(
      context, ticketId) async {
    Map<dynamic, dynamic> results = {};
    String apiUrl = '$apiBase/apitickets/loadTicketResetPushSettings';

    await Webservice().loadHttp(
        context, apiUrl, {'ticket_id': ticketId}).then((v) => results = v);
    List<TicketResetPushSettingModel> settings = [];
    for (var item in results['settings']) {
      settings.add(TicketResetPushSettingModel.fromJson(item));
    }

    return settings;
  }

  Future<bool> deleteResetPushSettings(context, String id) async {
    String apiUrl = '$apiBase/apitickets/deleteTicketResetPushSettings';

    await Webservice().loadHttp(context, apiUrl, {'setting_id': id});

    return true;
  }
}
