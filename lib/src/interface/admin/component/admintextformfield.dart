import 'package:flutter/material.dart';

class AdminTextInputDefualt extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? multiline;
  final String? errorText;
  const AdminTextInputDefualt({
    required this.controller,
    required this.hintText,
    this.multiline,
    this.errorText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: multiline,
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12),
          isDense: true,
          hintText: hintText,
          errorText: errorText,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey))),
    );
  }
}
