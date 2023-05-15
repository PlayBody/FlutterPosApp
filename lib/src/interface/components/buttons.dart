import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/common/functions/datetimes.dart';

var btnTxtStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

var btnTxtStyle1 =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -1);

//----degine complete ----------
class PrimaryButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const PrimaryButton({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff117fc1),
      ),
      onPressed: tapFunc,
      child: Text(label, style: btnTxtStyle),
    ));
  }
}

class PrimaryColButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const PrimaryColButton({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xff117fc1),
      ),
      onPressed: tapFunc,
      child: Text(label, style: btnTxtStyle1),
    );
  }
}

class CancelButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const CancelButton({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xff868686),
      ),
      onPressed: tapFunc,
      child: Text(label, style: btnTxtStyle),
    ));
  }
}

class CancelColButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const CancelColButton({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xff868686),
      ),
      onPressed: tapFunc,
      child: Text(label, style: btnTxtStyle1),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const DeleteButton({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xffee385a),
      ),
      onPressed: tapFunc,
      child: Text(label, style: btnTxtStyle),
    ));
  }
}

class DeleteColButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const DeleteColButton({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xffee385a),
      ),
      onPressed: tapFunc,
      child: Text(label, style: btnTxtStyle1),
    );
  }
}

class WhiteButton extends StatelessWidget {
  final String label;
  final Icon? icon;
  final GestureTapCallback? tapFunc;
  const WhiteButton({required this.label, this.icon, this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: const Color(0xffe3e3e3), onPrimary: const Color(0xff454545)),
      onPressed: tapFunc,
      child: icon == null
          ? Text(label, style: btnTxtStyle)
          : Row(
              children: [icon!, Text(label, style: btnTxtStyle)],
            ),
    );
  }
}

class LabelButton extends StatelessWidget {
  final String label;
  final tapFunc;
  final color;
  const LabelButton({required this.label, this.tapFunc, this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: color == null ? Color(0xffe3e3e3) : color,
        onPrimary: color == null ? Color(0xff454545) : Colors.white,
        padding: EdgeInsets.all(0),
        visualDensity: VisualDensity(vertical: -3),
      ),
      onPressed: tapFunc,
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class IconWhiteButton extends StatelessWidget {
  final IconData icon;
  final backColor;
  final color;
  final tapFunc;
  const IconWhiteButton(
      {required this.icon,
      required this.tapFunc,
      this.color,
      this.backColor,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: backColor == null ? Color(0xffe3e3e3) : backColor,
        onPrimary: Color(0xff454545),
        padding: EdgeInsets.all(0),
        visualDensity: VisualDensity(vertical: -3),
      ),
      onPressed: tapFunc,
      child: Icon(
        icon,
        color: color == null ? Colors.grey : color,
        size: 18,
      ),
    );
  }
}

class FullScreenButton extends StatelessWidget {
  final IconData icon;
  final tapFunc;
  const FullScreenButton({required this.icon, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapFunc,
      child: Icon(
        icon,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

class DatepickerIconBtn extends StatelessWidget {
  final tapFunc;
  const DatepickerIconBtn({required this.tapFunc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapFunc,
      child: Icon(
        Icons.calendar_today_sharp,
        color: Colors.blue,
        size: 20,
      ),
    );
  }
}

class PosDatepicker extends StatelessWidget {
  final DateTime selectedDate;
  final tapFunc;
  const PosDatepicker(
      {required this.selectedDate, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(DateTimes().convertJPYMDFromDateTime(selectedDate, isFull: true),
            style: TextStyle(fontSize: 16)),
        DatepickerIconBtn(tapFunc: tapFunc)
      ],
    );
  }
}
