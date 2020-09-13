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
      Text('Do, Fund and Done',
          style: TextStyle(fontWeight: FontWeight.normal)),
      Expanded(
        child: Image.asset('assets/images/tutorial_pics-01.png'),
      ),
    ]);
  }
}
