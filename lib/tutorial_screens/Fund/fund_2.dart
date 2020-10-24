import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

class Fund2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("A Fundder is our name for fundraisers within the app.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
                child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border:
                            Border.all(width: 2, color: HexColor('ff6b6c'))),
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
                          TextSpan(
                              text: 'promises to sing ', style: TextStyle()),
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
        ]);
  }
}
