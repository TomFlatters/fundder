import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/buttons.dart';

class Fund4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Donations', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
              'You can donate by opening the Fundder detailed view through the feed and pressing',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
              child: PrimaryFundderButton(text: 'Donate', onPressed: () {}),
            ),
          ),
          Text('as a sign of appreciation',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Container(),
          )
        ]);
  }
}
