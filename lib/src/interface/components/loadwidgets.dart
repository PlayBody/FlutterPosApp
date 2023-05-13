import 'package:flutter/material.dart';
import 'package:staff_pos_app/src/interface/layout/myappbar.dart';
import 'package:staff_pos_app/src/interface/layout/mydrawer.dart';
import 'package:staff_pos_app/src/interface/layout/subbottomnavi.dart';

// import 'package:syncfusion_flutter_charts/charts.dart';

class LoadBodyWdiget extends StatelessWidget {
  final loadData;
  final Widget render;
  const LoadBodyWdiget({required this.loadData, required this.render, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: loadData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: render,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a loading spinner.
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class MainBodyWdiget extends StatelessWidget {
  final Widget render;
  final resizeBottom;
  final bool? isFullScreen;
  final fullScreenButton;
  final double? fullscreenTop;
  const MainBodyWdiget({
    required this.render,
    this.resizeBottom,
    this.isFullScreen,
    this.fullscreenTop,
    this.fullScreenButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          resizeToAvoidBottomInset: resizeBottom == null ? true : resizeBottom,
          backgroundColor: Colors.transparent,
          appBar: (isFullScreen == null || isFullScreen == false)
              ? MyAppBar()
              : null,
          body: Stack(children: [
            render,
            if (fullScreenButton != null)
              Positioned(
                  left: 0,
                  top: fullscreenTop == null ? 105 : fullscreenTop,
                  child: fullScreenButton)
          ]),
          drawer: MyDrawer(),
          bottomNavigationBar: (isFullScreen == null || isFullScreen == false)
              ? SubBottomNavi()
              : null),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
