import 'package:flutter/material.dart';
import 'admin_labels.dart';

class AdminRowForm extends StatelessWidget {
  final String label;
  final Widget renderWidget;
  final double? hMargin;
  final double? vMargin;
  final double? labelWidth;
  final double? labelPadding;
  const AdminRowForm(
      {required this.label,
      required this.renderWidget,
      this.hMargin,
      this.vMargin,
      this.labelWidth,
      this.labelPadding,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: hMargin == null ? 0 : hMargin!,
        vertical: vMargin == null ? 0 : vMargin!,
      ),
      child: Row(
        children: [
          AdminRowLabel(
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
