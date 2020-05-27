// root authentication widget

import "package:flutter/material.dart";
import 'package:fundder/auth_screens/register.dart';
import 'package:fundder/auth_screens/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Register(),
    );
  }
}