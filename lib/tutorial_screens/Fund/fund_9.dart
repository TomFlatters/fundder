import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';

class Fund9 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "If you do not meet your target, your donors will automatically be refunded.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                child:
                    Icon(Ionicons.ios_sad, color: HexColor('ff6b6c'), size: 60),
              ),
            ),
          ),
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
                        text:
                            "Unless you choose to 'complete' it anyway and upload - in which case the pot will be donated, and your Fundder moved to the ",
                        style: TextStyle()),
                    TextSpan(
                        text: 'Done ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(text: 'feed!', style: TextStyle()),
                  ])),
          SizedBox(height: 20),
          Text("You can always 'complete' a post early - before the 14 days.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
        ]);
  }
}
