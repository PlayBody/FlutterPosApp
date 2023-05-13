import 'package:flutter/material.dart';

typedef void StringCallback(String val);

class AdminInputFormField extends StatelessWidget {
  final String? hintText;
  final int? maxLine;
  final String? errorText;
  final TextEditingController? txtController;

  final StringCallback? callback;

  const AdminInputFormField(
      {this.hintText,
      this.maxLine,
      this.errorText,
      this.txtController,
      this.callback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: txtController,
      decoration: InputDecoration(
        errorText: errorText,
        hintText: this.hintText,
        contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        filled: true,
        hintStyle: TextStyle(color: Colors.grey),
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(color: Colors.grey)),
      ),
      maxLines: this.maxLine == null ? 1 : this.maxLine,
      onChanged: callback == null
          ? null
          : (v) {
              callback!(v);
            },
    );
  }
}
