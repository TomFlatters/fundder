import 'package:flutter/material.dart';
import 'tutorial_screen_controller.dart';
import 'Fund/fund_1.dart';
import 'Fund/fund_2.dart';
import 'Fund/fund_3.dart';
import 'Fund/fund_4.dart';
import 'Fund/fund_5.dart';

class FundTutorial extends StatelessWidget {
  final List<Widget> fundScreens = [
    Fund1(),
    Fund2(),
    Fund3(),
    Fund4(),
    Fund5(),
  ];

  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(this.fundScreens, 'tutorialSeenV2');
  }
}
