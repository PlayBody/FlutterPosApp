import 'package:flutter/material.dart';

class PosDlgHeaderText extends StatelessWidget {
  final String label;
  const PosDlgHeaderText({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 30),
        child: Text(label,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)));
  }
}

class PosDlgSubHeaderText extends StatelessWidget {
  final String label;
  final double? bottomPadding;
  const PosDlgSubHeaderText({required this.label, this.bottomPadding, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: bottomPadding != null
            ? EdgeInsets.only(bottom: bottomPadding!)
            : EdgeInsets.only(bottom: 24),
        child: Text(label, style: TextStyle(fontSize: 20, letterSpacing: 2)));
  }
}

class SubHeaderText extends StatelessWidget {
  final String label;
  const SubHeaderText({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Text(label, style: TextStyle(fontSize: 16, letterSpacing: 2)));
  }
}

class PosDlgInputLabelText extends StatelessWidget {
  final String label;
  final Alignment? align;
  const PosDlgInputLabelText({required this.label, this.align, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      alignment: align == null ? Alignment.centerLeft : align,
      child: Text(label, style: TextStyle(fontSize: 16)),
    );
  }
}

//------------degin complete ---------------

class PageSubHeader extends StatelessWidget {
  final String label;
  const PageSubHeader({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      color: Color(0xff117fc1),
      child: Text(
        label,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2),
      ),
    );
  }
}

class InputLeftText extends StatelessWidget {
  final String label;
  final double? width;
  final double? rPadding;
  const InputLeftText(
      {required this.label, this.width, this.rPadding, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: rPadding == null ? 25 : rPadding!),
      width: width == null ? 100 : width,
      child: Text(label,
          style: TextStyle(
              fontSize: 14,
              color: Color(0xff1d4874),
              fontWeight: FontWeight.bold)),
    );
  }
}

class ListHeader1 extends StatelessWidget {
  final String label;
  final Alignment? txtAlign;
  const ListHeader1({required this.label, this.txtAlign, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: txtAlign == null ? Alignment.center : txtAlign,
        padding: EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
  }
}
