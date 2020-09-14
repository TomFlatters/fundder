import 'package:flutter/material.dart';
import 'tutorial_screen_controller.dart';
import 'Done/done_1.dart';

class DoneTutorial extends StatelessWidget {
  final List<Widget> doneScreens = [Done1()];
  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(this.doneScreens);
  }
}
