import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';

class Profile1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('This is the profile view.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          SizedBox(
            height: 20,
          ),
          Text(
              'Here you can edit your profile, view followers and view your liked posts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Icon(
                    AntDesign.user,
                    size: 60,
                    color: HexColor('ff6b6c'),
                  )),
            ),
          ),
          Text('Note: only you can see your own liked posts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
        ]);
  }
}
