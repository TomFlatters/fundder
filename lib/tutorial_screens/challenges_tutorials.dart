import 'package:flutter/material.dart';
import 'tutorial_screen_controller.dart';
import 'Challenges/challenges_1.dart';

class ChallengesTutorial extends StatelessWidget {
  final List<Widget> challengeScreens = [Challenges1()];

  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(
        this.challengeScreens, 'challengesTutorialSeen');
  }
}
