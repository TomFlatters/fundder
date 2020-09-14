import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';

class Do2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("You can create a challege for someone else by pressing",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Icon(AntDesign.plussquareo,
                    color: HexColor('ff6b6c'), size: 60),
              ),
            ),
          ),
          Text("in the bottom bar (just like creating your own Fundder).",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: Container(),
            ),
          ),
        ]);
  }
}
