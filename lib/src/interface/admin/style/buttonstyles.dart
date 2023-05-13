import 'package:flutter/material.dart';

var styleGroupButton = ElevatedButton.styleFrom(
  padding: EdgeInsets.all(0),
  side: BorderSide(
    width: 1,
    color: Color.fromARGB(255, 200, 200, 200),
  ),
  primary: Colors.white, //Color.fromARGB(255, 160, 30, 30),
  onPrimary: Colors.black,
  elevation: 0,
);

// grey button
var greyButtonDefualt = ElevatedButton.styleFrom(primary: Colors.grey);
