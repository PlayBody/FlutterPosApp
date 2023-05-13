import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/style/textstyles.dart';

class CheckNomal extends StatelessWidget {
  final String label;
  final double? scale;
  final bool value;
  final tapFunc;
  const CheckNomal(
      {required this.label,
      required this.value,
      this.scale,
      this.tapFunc,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Theme(
            child: Transform.scale(
              scale: scale == null ? 1 : scale!,
              child: Checkbox(
                  activeColor: Color(0xff117fc1),
                  value: value,
                  splashRadius: 3,
                  onChanged: tapFunc),
            ),
            data: ThemeData(
              unselectedWidgetColor: Color(0xffbebebe), // Your color
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 8),
              child: Text(label, style: bodyTextStyle))
        ],
      ),
    );
  }
}
