import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/apiendpoint.dart';
import 'package:staff_pos_app/src/common/dialogs.dart';
import 'package:staff_pos_app/src/common/messages.dart';
import 'package:staff_pos_app/src/http/webservice.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';
import 'package:staff_pos_app/src/interface/components/buttons.dart';
import 'package:staff_pos_app/src/interface/components/form_widgets.dart';
import 'package:staff_pos_app/src/interface/components/loadwidgets.dart';

import '../../../common/globals.dart' as globals;

class AdminTeacherAdd extends StatefulWidget {
  final String? teacherId;
  const AdminTeacherAdd({this.teacherId, Key? key}) : super(key: key);

  @override
  _AdminTeacherAdd createState() => _AdminTeacherAdd();
}

class _AdminTeacherAdd extends State<AdminTeacherAdd> {
  var txtController = TextEditingController();

  String? errText;

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveTeacher() async {
    bool isFormCheck = true;

    if (txtController.text == '') {
      isFormCheck = false;
      errText = warningCommonInputRequire;
    } else {
      errText = null;
    }
    setState(() {});
    if (!isFormCheck) return;

    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiSaveTeacherUrl, {
      'company_id': globals.companyId,
      'teacer_id': widget.teacherId == null ? '' : widget.teacherId,
      'teacher_name': txtController.text
    }).then((value) => results = value);

    if (results['isSave']) {
      Navigator.pop(context);
    } else {
      Dialogs().infoDialog(context, errServerActionFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.adminAppTitle = '先生登録';
    return MainBodyWdiget(
      render: Container(
          padding: paddingMainContent,
          child: Column(
            children: [
              TextFormField(
                controller: txtController,
                decoration: InputDecoration(
                  errorText: errText,
                  hintText: '先生名',
                  contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
              RowButtonGroup(widgets: [
                PrimaryButton(label: '作成', tapFunc: () => saveTeacher())
              ])
            ],
          )),
    );
  }
}
