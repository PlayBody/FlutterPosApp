import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/business/ticket.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';
import 'package:staff_pos_app/src/interface/pos/manage/tickets/ticketedit.dart';
import 'package:staff_pos_app/src/model/menumodel.dart';
import 'package:staff_pos_app/src/model/organmodel.dart';
import 'package:staff_pos_app/src/model/ticketmodel.dart';

import 'package:staff_pos_app/src/common/globals.dart' as globals;

var txtAccountingController = TextEditingController();
var txtMenuCountController = TextEditingController();
var txtSetTimeController = TextEditingController();
var txtSetAmountController = TextEditingController();
var txtTableAmountController = TextEditingController();

class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  _TicketList createState() => _TicketList();
}

class _TicketList extends State<TicketList> {
  late Future<List> loadData;
  String isAdmin = '0';
  List<MenuModel> menuList = [];
  String? selOrganId;

  List<OrganModel> organList = [];

  List<TicketModel> tickets = [];

  @override
  void initState() {
    super.initState();
    loadData = loadTicketData();
  }

  Future<List> loadTicketData() async {
    tickets = await ClTicket().loadTicketList(context);
    setState(() {});
    return tickets;
  }

  Future<void> pushTicketUpdate(String? ticketId, String companyId) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) {
      return TicketEdit(
        id: ticketId,
        companyId: companyId,
      );
    }));

    loadTicketData();
  }

  @override
  Widget build(BuildContext context) {
    globals.appTitle = 'チケット管理';
    return MainBodyWdiget(
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: bodyColor,
              child: Column(
                children: [
                  Expanded(
                    child: _getTicketListContent(),
                  ),
                  RowButtonGroup(
                    widgets: [
                      PrimaryButton(
                          label: '新規登録', tapFunc: () => pushTicketUpdate(null, globals.auth < constAuthSystem ? globals.companyId : '')),
                    ],
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _getTicketListContent() {
    return ListView(
      children: [
        ...tickets.map(
          (e) => Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.title + ' [' + e.name + ']',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 4),
                WhiteButton(
                  tapFunc: () => pushTicketUpdate(e.id, e.companyId),
                  label: '変更',
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
