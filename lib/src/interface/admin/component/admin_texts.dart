import 'package:flutter/material.dart';

class AdminCommentText extends StatelessWidget {
  final String label;
  const AdminCommentText({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }
}

class AdminHeader4 extends StatelessWidget {
  final String label;
  const AdminHeader4({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }
}
