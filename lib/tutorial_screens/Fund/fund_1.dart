import 'package:flutter/material.dart';

class Fund1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('Welcome to Fundder', style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text('This is the feed.',
          style: TextStyle(fontWeight: FontWeight.normal)),
      SizedBox(
        height: 20,
      ),
      Text('The feed contains 3 tabs:',
          style: TextStyle(fontWeight: FontWeight.normal)),
      RichText(
          text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontFamily: 'Founders Grotesk',
              ),
              children: [
            TextSpan(
                text: 'Do',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
            TextSpan(text: ', ', style: TextStyle()),
            TextSpan(
                text: 'Fund ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
            TextSpan(text: 'and ', style: TextStyle()),
            TextSpan(
                text: 'Done',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
          ])),
      Expanded(
        child: Center(
          child: Container(
              margin: EdgeInsets.all(20),
              child: Image.asset('assets/images/tutorial_pics-01.png')),
        ),
      ),
    ]);
  }
}
