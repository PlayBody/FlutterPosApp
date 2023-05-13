import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/admin/style/paddings.dart';

class AdminSearch extends StatelessWidget {
  final tapFunc;
  const AdminSearch({required this.tapFunc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingAdminSearchBottom,
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, size: 24, color: Colors.grey),
          contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          filled: true,
          hintText: '検索',
          hintStyle: TextStyle(color: Colors.grey),
          fillColor: Colors.white.withOpacity(0.5),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: BorderSide(color: Colors.grey)),
        ),
        onChanged: (v) {},
      ),
    );
  }
}
