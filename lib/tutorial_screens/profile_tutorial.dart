import 'package:flutter/material.dart';
import 'tutorial_screen_controller.dart';
import 'profile/profile_1.dart';

class ProfileTutorial extends StatelessWidget {
  final List<Widget> profileScreens = [
    Profile1(),
  ];
  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(this.profileScreens);
  }
}
