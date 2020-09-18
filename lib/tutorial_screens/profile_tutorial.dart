import 'package:flutter/material.dart';
import 'package:fundder/tutorial_screens/Profile/profile_1.dart';
import 'tutorial_screen_controller.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileTutorial extends StatelessWidget {
  final List<Widget> profileScreens = [
    Profile1(),
  ];

  @override
  Widget build(BuildContext context) {
    return TutorialScreenController(this.profileScreens, 'profileTutorialSeen');
  }
}
