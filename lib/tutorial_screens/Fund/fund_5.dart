import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/buttons.dart';

class Fund5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Completing Fundders',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('You can complete Fundders by pressing',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: PrimaryFundderButton(text: 'Progress', onPressed: () {}),
            ),
          ),
          Text('on its detailed view',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Container(),
          )
        ]);
  }
}
