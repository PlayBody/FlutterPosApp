import 'package:flutter/material.dart';

class AdminRowLabel extends StatelessWidget {
  final String label;
  final double? width;
  final double? rPadding;
  const AdminRowLabel(
      {required this.label, this.width, this.rPadding, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: rPadding == null ? 25 : rPadding!),
      width: width ?? 100,
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
