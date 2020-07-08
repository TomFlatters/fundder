import 'package:flutter/material.dart';
import 'web_menu.dart';

class TemporaryUpload extends StatelessWidget {
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
            WebMenu(0),
            Container(height: 10),
            Center(child: Text('Posts can currently only be uploaded via app')),
          ],
        ),
      ),
    );
  }
}
