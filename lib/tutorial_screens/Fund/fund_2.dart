import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Fund2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('Challenges can move between the 3 tabs in the feed.',
          style: TextStyle(fontWeight: FontWeight.normal)),
      Expanded(
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Icon(
                    AntDesign.arrowdown,
                    size: 40,
                  ),
                  Text(
                    'Do',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              Icon(
                AntDesign.arrowright,
                size: 40,
              ),
              Column(
                children: [
                  Icon(
                    AntDesign.arrowdown,
                    size: 40,
                  ),
                  Text(
                    'Fund',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              Icon(
                AntDesign.arrowright,
                size: 40,
              ),
              Text(
                'Done',
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}
