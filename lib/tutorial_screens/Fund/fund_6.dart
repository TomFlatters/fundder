import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';

class Fund6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: 'Founders Grotesk',
                  ),
                  children: [
                    TextSpan(
                        text: 'To add your own Fundder to the ',
                        style: TextStyle()),
                    TextSpan(
                        text: 'Fund ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(
                        text:
                            'feed, you can either create your own by pressing',
                        style: TextStyle()),
                  ])),
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Icon(AntDesign.plussquareo,
                    color: HexColor('ff6b6c'), size: 60),
              ),
            ),
          ),
          Text("in the bottom bar",
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
