import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

class Fund3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "Your followers 'crowdfund' your Fundder! They have 14 days! (but you can extend that)",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          SizedBox(
            height: 20,
          ),
          Text(
              "When you reach your target amount, you will be prompted to complete the challenge you set yourself in the Fundder.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Container(),
          )
        ]);
  }
}
