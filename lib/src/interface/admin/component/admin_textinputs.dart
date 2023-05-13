import 'package:flutter/material.dart';

class AdminTextInputNormal extends StatelessWidget {
  final controller;
  final String? hintText;
  final String? errorText;
  final double? contentPadding;
  final double? fontsize;
  final TextInputType? inputType;
  final bool? obscureText;
  const AdminTextInputNormal(
      {required this.controller,
      this.errorText,
      this.hintText,
      this.contentPadding,
      this.inputType,
      this.fontsize,
      this.obscureText = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText!,
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        errorText: errorText,
        isDense: true,
        contentPadding:
            EdgeInsets.all(contentPadding == null ? 8 : contentPadding!),
        fillColor: Colors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFbebebe)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFbebebe)),
        ),
      ),
      style: TextStyle(fontSize: fontsize == null ? 14 : fontsize),
    );
  }
}
