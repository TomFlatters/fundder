import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Fund5 extends StatelessWidget {
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
                    TextSpan(text: 'The ', style: TextStyle()),
                    TextSpan(
                        text: 'Fund ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(
                        text: 'feed contains Fundders currently raising money.',
                        style: TextStyle()),
                  ])),
          Expanded(
            child: Center(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Image.asset('assets/images/tutorial_pics-02.png')),
            ),
          ),
        ]);
  }
}
