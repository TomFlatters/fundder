import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

class Fund1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('Welcome to Fundder', style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text("A Fundder is also our name for challenges within the app.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal)),
      Expanded(
        child: Center(
            child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(width: 2, color: HexColor('ff6b6c'))),
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontFamily: 'Founders Grotesk',
                        ),
                        children: [
                      TextSpan(text: '"', style: TextStyle()),
                      TextSpan(
                          text: 'The rugby team ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          )),
                      TextSpan(text: 'promises to sing ', style: TextStyle()),
                      TextSpan(
                          text: 'California Girls by Katy Perry ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          )),
                      TextSpan(text: 'on Sunday 12pm ', style: TextStyle()),
                      TextSpan(
                          text: '@Cornmarket Street, ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          )),
                      TextSpan(text: 'if ', style: TextStyle()),
                      TextSpan(
                          text: '£15 ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          )),
                      TextSpan(text: 'is donated to ', style: TextStyle()),
                      TextSpan(
                          text: 'Oxfordshire Mind."',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          )),
                    ])))),
      ),
      /*Text('This is the feed.',
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
      ),*/
    ]);
  }
}
