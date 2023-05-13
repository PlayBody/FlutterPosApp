import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';

class RadioNomal extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final tapFunc;
  const RadioNomal(
      {required this.label,
      required this.value,
      required this.groupValue,
      this.tapFunc,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 6,
                  color: groupValue == value ? Color(0xff117fc1) : Colors.grey),
              borderRadius: BorderRadius.circular(20)),
        ),
        Container(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Text(label, style: bodyTextStyle),
        )
      ]),
      onTap: tapFunc,
    );
  }
}
