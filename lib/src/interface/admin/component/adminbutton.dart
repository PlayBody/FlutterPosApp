import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/admin/style/textstyles.dart';

class AdminAddButton extends StatelessWidget {
  final String label;
  final GestureTapCallback tapFunc;
  const AdminAddButton({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: ElevatedButton(
            onPressed: tapFunc,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(8),
                side: const BorderSide(width: 1, color: Colors.grey),
                primary: Colors.white, //Color.fromARGB(255, 160, 30, 30),
                onPrimary: Colors.grey,
                elevation: 0,
                textStyle: const TextStyle(fontSize: 20)),
            child: Row(children: [
              const SizedBox(width: 10),
              Text(label),
            ])));
  }
}

class AdminUserTicketAddButton extends StatelessWidget {
  final GestureTapCallback tapFunc;
  const AdminUserTicketAddButton({required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: ElevatedButton(
              onPressed: tapFunc,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                  side: const BorderSide(
                    width: 0.5,
                    color: Colors.black,
                  ),
                  primary: Colors.white, //Color.fromARGB(255, 160, 30, 30),
                  onPrimary: Colors.black,
                  elevation: 0,
                  textStyle: styleAddButtonText),
              child: const Text('すべてのユーザーのチケットを+1枚')))
    ]);
  }
}

class AdminBtnIconRemove extends StatelessWidget {
  final GestureTapCallback tapFunc;
  const AdminBtnIconRemove({required this.tapFunc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0.0),
      icon: const Icon(Icons.delete, color: Colors.redAccent),
      onPressed: tapFunc,
    );
  }
}

class AdminBtnIconDefualt extends StatelessWidget {
  final GestureTapCallback tapFunc;
  final IconData icon;
  const AdminBtnIconDefualt(
      {required this.tapFunc, required this.icon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0.0),
      icon: Icon(icon, color: Colors.blue),
      onPressed: tapFunc,
    );
  }
}

class AdminBtnCircleIcon extends StatelessWidget {
  final GestureTapCallback tapFunc;
  final IconData icon;
  const AdminBtnCircleIcon(
      {required this.tapFunc, required this.icon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: tapFunc,
        child: Container(
          margin: const EdgeInsets.all(4),
          width: 24,
          height: 24,
          // padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(30)),
          child: Icon(icon, color: Colors.white, size: 18),
        ));
  }
}

class AdminBtnCircleClose extends StatelessWidget {
  final GestureTapCallback tapFunc;
  const AdminBtnCircleClose({required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapFunc,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.close, size: 18, color: Colors.white),
      ),
    );
  }
}

class AdminPrimaryBtn extends StatelessWidget {
  final String label;
  final GestureTapCallback tapFunc;
  const AdminPrimaryBtn({required this.label, required this.tapFunc, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: tapFunc, child: Text(label));
  }
}
