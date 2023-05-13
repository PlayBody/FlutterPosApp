import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/admin/style/fontsizes.dart';

var styleItemGroupTitle =
    TextStyle(fontWeight: FontWeight.bold, fontSize: sizeItemGroupTitle);

var styleContent = TextStyle(fontSize: sizeNormalPage);

var styleUserName1 =
    TextStyle(fontWeight: FontWeight.bold, fontSize: sizeUserName1);

var styleAddButtonText = TextStyle(fontSize: sizeAddButtonText);

var stylePageSubtitle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

var decorationSearch = InputDecoration(
  prefixIcon: Icon(Icons.search, size: 24, color: Colors.grey),
  contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
  filled: true,
  hintText: '検索',
  hintStyle: TextStyle(color: Colors.grey),
  fillColor: Colors.white.withOpacity(0.5),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: BorderSide(color: Colors.grey)),
);

var decorationInputText = InputDecoration(
  contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
  filled: true,
  hintText: '',
  hintStyle: TextStyle(color: Colors.grey),
  fillColor: Colors.white.withOpacity(0.5),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: BorderSide(color: Colors.grey)),
);
