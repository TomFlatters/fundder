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
    final user = Provider.of<User>(context);
    Size size = MediaQuery.of(context).size;
    if (user != null) {
      Future.microtask(() => Navigator.pushNamed(context, '/web/feed'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Founders Grotesk',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
      // This size provide us total height and width  of our screen
      return Scaffold(
        body: Container(
          height: size.height,
          // it will take full width
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[WebMenu(-1), Expanded(child: Authenticate())],
          ),
        ),
      );
    }
  }
}
