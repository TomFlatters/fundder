import 'package:flutter/material.dart';
import 'web_menu.dart';
import 'package:fundder/feed.dart';
import 'package:fundder/do_challenge.dart';
import 'package:fundder/feed_controller.dart';

class DoWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width  of our screen
    return Scaffold(
      body: Container(
        height: size.height,
        // it will take full width
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WebMenu(),
            Spacer(),
            // It will cover 1/3 of free spaces
            DoChallenge(),
            Spacer(
              flex: 2,
            ),
            // it will cover 2/3 of free spaces
          ],
        ),
      ),
    );
  }
}
