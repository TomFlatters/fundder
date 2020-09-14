import 'package:flutter/material.dart';

class Fund7 extends StatelessWidget {
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
                        text: 'Or you can accept an active challenge from the ',
                        style: TextStyle()),
                    TextSpan(
                        text: 'Do ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(text: 'feed.', style: TextStyle()),
                  ])),
          Expanded(
            child: Center(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Image.asset('assets/images/tutorial_pics-04.png')),
            ),
          ),
        ]);
  }
}
