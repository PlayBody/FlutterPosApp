import 'package:flutter/material.dart';

class TextInputNormal extends StatelessWidget {
  final controller;
  final String? hintText;
  final String? errorText;
  final double? contentPadding;
  final TextInputType? inputType;
  final int? multiLine;
  final bool? isEnable;
  final bool? obscureText;
  final String? caption;
  const TextInputNormal(
      {required this.controller,
      this.errorText,
      this.hintText,
      this.contentPadding,
      this.inputType,
      this.multiLine,
      this.isEnable,
      this.obscureText = false,
      this.caption,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText!,
      enabled: isEnable ?? true,
      controller: controller,
      keyboardType: inputType,
      maxLines: multiLine == null ? 1 : 5,
      decoration: InputDecoration(
        label: caption == null ? null : Text(caption!),
        errorText: errorText,
        isDense: true,
        contentPadding:
            EdgeInsets.all(contentPadding == null ? 10 : contentPadding!),
        fillColor: Colors.white,
        filled: true,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFbebebe)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFbebebe)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFbebebe)),
        ),
      ),
      style: const TextStyle(fontSize: 12),
    );
  }
}
