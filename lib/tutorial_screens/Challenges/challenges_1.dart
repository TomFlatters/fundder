import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/buttons.dart';

class Challenges1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Challenges', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
              'Here you can view challenges for you and by you. You can add a challenge by pressing',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: PrimaryFundderButton(text: 'Create', onPressed: () {}),
            ),
          ),
          Expanded(
            child: Container(),
          )
        ]);
  }
}
