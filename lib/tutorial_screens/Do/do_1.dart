import 'package:flutter/material.dart';

class Do1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: 'Founders Grotesk',
                  ),
                  children: [
                TextSpan(text: 'This is the ', style: TextStyle()),
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
          Text(
              "This contains challeges that you can accept to create your own Fundder.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          SizedBox(
            height: 20,
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
                        text: 'Once you accept, the Fundder appears in the ',
                        style: TextStyle()),
                    TextSpan(
                        text: 'Fund ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(text: 'feed under your name.', style: TextStyle()),
                  ])),
        ]);
  }
}
