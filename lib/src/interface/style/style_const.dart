import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

//------------------ shift TimeSlotView ----------------------
var shiftOrganDisableColor = Colors.grey.withOpacity(0.2);
var timeSlotCellBorderColor = Colors.grey.withOpacity(0.9);

var timeSlotCellHeight = 30;

var timeSlotSelectDecoration = BoxDecoration(
    border: Border.all(color: Colors.orange, width: 2),
    borderRadius: const BorderRadius.all(Radius.circular(4)));
var timeSlotViewSetting = TimeSlotViewSettings(
    timeIntervalHeight: timeSlotCellHeight.toDouble(),
    dayFormat: 'EEE',
    timeInterval: const Duration(minutes: 30),
    timeFormat: 'H:mm',
    timeTextStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      color: Colors.black.withOpacity(0.5),
    ));
var apppointmentsTextStyle = const TextStyle(
    fontSize: 18,
    color: Colors.black,
    letterSpacing: 1,
    fontWeight: FontWeight.bold);
