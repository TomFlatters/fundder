import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

class Fund2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('This is the feed',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 20,
          ),
          Text(
            'The feed contains Fundders which are both completed and ongoing',
            style: TextStyle(fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: Center(
              child: Row(children: [
                Expanded(
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: Image.asset('assets/images/tutorial_pics-02.png')),
                ),
                Expanded(
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: Image.asset('assets/images/tutorial_pics-05.png')),
                ),
              ]),
            ),
          ),
        ]);
  }
}
