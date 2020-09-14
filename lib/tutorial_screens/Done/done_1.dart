import 'package:flutter/material.dart';

class Done1 extends StatelessWidget {
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
                    TextSpan(text: 'This is the ', style: TextStyle()),
                    TextSpan(
                        text: 'Done ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(
                        text:
                            'feed. Here you can find completed Fundders. Browse through photos and videos of people doing weird and wonderful things.',
                        style: TextStyle()),
                  ])),
          Expanded(
            child: Center(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Image.asset('assets/images/tutorial_pics-05.png')),
            ),
          ),
        ]);
  }
}
