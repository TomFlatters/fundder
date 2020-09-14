import 'package:flutter/material.dart';
import 'tutorial_screen_controller.dart';
import 'Do/do_1.dart';
import 'Do/do_2.dart';

class DoTutorial extends StatelessWidget {
  final List<Widget> doScreens = [
    Do1(),
    Do2(),
  ];
  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(this.doScreens);
  }
}
