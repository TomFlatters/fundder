import 'package:flutter/material.dart';
import 'web_menu.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width  of our screen
    return Scaffold(
      body: Container(
        height: size.height,
        // it will take full width
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WebMenu(),
            // It will cover 1/3 of free spaces
            Text('This is the about page')
            // it will cover 2/3 of free spaces
          ],
        ),
      ),
    );
  }
}
