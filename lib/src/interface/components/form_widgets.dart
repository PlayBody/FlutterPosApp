import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/components/texts.dart';

class RowLabelInput extends StatelessWidget {
  final String label;
  final Widget renderWidget;
  final double? hMargin;
  final double? labelWidth;
  final double? labelPadding;
  final bool? isLabelTop;
  const RowLabelInput(
      {required this.label,
      required this.renderWidget,
      this.hMargin,
      this.labelWidth,
      this.labelPadding,
      this.isLabelTop,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: hMargin == null ? 0 : hMargin!, vertical: 6),
      child: Row(
        crossAxisAlignment: (isLabelTop != null && isLabelTop!)
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          InputLeftText(
            label: label,
            rPadding: labelPadding,
            width: labelWidth,
          ),
          Flexible(child: renderWidget)
        ],
      ),
    );
  }
}

class RowButtonGroup extends StatelessWidget {
  final List<Widget> widgets;
  final bgColor;
  const RowButtonGroup({required this.widgets, this.bgColor, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor == null ? Color(0xfffbfbfb) : bgColor,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 30),
          ...widgets.map((e) => e),
          SizedBox(width: 30),
        ],
      ),
    );
  }
}
