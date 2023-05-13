import 'package:flutter/material.dart';

class BadgeContent extends StatelessWidget {
  final int badgeCount;
  const BadgeContent({required this.badgeCount, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(30)),
      child: Text(
        badgeCount.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
