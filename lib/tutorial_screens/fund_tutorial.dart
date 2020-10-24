import 'package:flutter/material.dart';
import 'tutorial_screen_controller.dart';
import 'Fund/fund_1.dart';
import 'Fund/fund_2.dart';
import 'Fund/fund_3.dart';
import 'Fund/fund_4.dart';
import 'Fund/fund_5.dart';
import 'Fund/fund_6.dart';
import 'Fund/fund_7.dart';
import 'Fund/fund_8.dart';
import 'Fund/fund_9.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FundTutorial extends StatelessWidget {
  final List<Widget> fundScreens = [
    Fund1(),
    Fund4(),
    Fund2(),
    // Fund3(),
    Fund5(),
    Fund6(),
    Fund7(),
    Fund8(),
    Fund9()
  ];

  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(this.fundScreens, 'fundTutorialSeen');
  }
}
