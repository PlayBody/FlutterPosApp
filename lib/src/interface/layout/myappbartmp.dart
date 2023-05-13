import 'package:flutter/material.dart';

import '../../common/globals.dart' as globals;
// Set up a mock HTTP client.

class MyAppBarTmp extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(globals.appTitle),
      actions: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 32, 20, 0),
          child: Text(globals.loginEmail,
              style: TextStyle(
                fontSize: 14,
              )),
        )
      ],
    );
  }
}
