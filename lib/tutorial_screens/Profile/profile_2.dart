import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';

class Profile2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              'Press the three dots in the top right corner to view more options.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Icon(
                    AntDesign.ellipsis1,
                    size: 60,
                    color: HexColor('ff6b6c'),
                  )),
            ),
          ),
          Text(
              'Here you can make your profile private or find facebook friends.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
        ]);
  }
}
