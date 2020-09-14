import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/buttons.dart';

class Fund8 extends StatelessWidget {
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
                        text:
                            'Your followers then crowdfund your Fundder in the ',
                        style: TextStyle()),
                    TextSpan(
                        text: 'Fund ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(
                        text: 'feed! They have 14 days! (which you can extend)',
                        style: TextStyle()),
                  ])),
          Expanded(
            child: Center(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Image.asset('assets/images/tutorial_pics-06.png')),
            ),
          ),
          Text(
              "When you reach the target amount, you will be prompted to 'complete' your Fundder challenge.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
        ]);
  }
}
