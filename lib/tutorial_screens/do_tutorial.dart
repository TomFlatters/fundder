import 'package:flutter/material.dart';
import 'tutorial_screen_controller.dart';
import 'Do/do_1.dart';
import 'Do/do_2.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoTutorial extends StatelessWidget {
  final List<Widget> doScreens = [
    Do1(),
    Do2(),
  ];
  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(this.doScreens, 'doTutorialSeen');
  }
}
