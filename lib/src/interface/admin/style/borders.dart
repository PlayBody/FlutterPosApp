import 'package:flutter/cupertino.dart';

var borderColor = Color.fromARGB(255, 200, 200, 200);

var borderAllRadius8 = BoxDecoration(
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: borderColor, width: 1),
);

var borderBottomLine = BoxDecoration(
  border: Border(bottom: BorderSide(color: borderColor, width: 1)),
);

var borderTopLine = BoxDecoration(
  border: Border(top: BorderSide(color: borderColor, width: 1)),
);

var borderTopBottomLine = BoxDecoration(
  border: Border(
      top: BorderSide(color: borderColor, width: 1),
      bottom: BorderSide(color: borderColor, width: 1)),
);
