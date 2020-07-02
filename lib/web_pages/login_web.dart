import 'package:flutter/material.dart';
import 'web_menu.dart';
import 'package:fundder/auth_screens/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/auth.dart';

class LoginWeb extends StatefulWidget {
  @override
  _LoginWebState createState() => _LoginWebState();
}

class _LoginWebState extends State<LoginWeb> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // This size provide us total height and width  of our screen
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: Container(
        height: size.height,
        // it will take full width
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[WebMenu(), Expanded(child: Authenticate())],
        ),
      ),
    );
  }
}
