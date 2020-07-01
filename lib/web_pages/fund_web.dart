import 'package:flutter/material.dart';
import 'web_menu.dart';
import 'package:fundder/feed.dart';
import 'package:fundder/do_challenge.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/user.dart';

class FundWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width  of our screen
    return Scaffold(
      body: Container(
        height: size.height,
        // it will take full width
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            WebMenu(),
            // It will cover 1/3 of free spaces
            Expanded(
                child: Container(
              width: 400,
              child: FeedView("Fund", null, HexColor('ff6b6c'),
                  DatabaseService(uid: user.uid).posts),
            )),
            // it will cover 2/3 of free spaces
          ],
        ),
      ),
    );
  }
}
