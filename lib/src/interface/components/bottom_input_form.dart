import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BottomModal {
  Future inputFromDialog(context, String formTitle, Widget bodyContent) {
    return showBarModalBottomSheet(
        // expand: false,
        context: context,
        backgroundColor: Colors.white,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  child: Text(
                    formTitle,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                bodyContent,
                Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                )
              ],
            );
          });
        });
  }
}
