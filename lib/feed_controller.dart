// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'view_post_controller.dart';
import 'share_post_controller.dart';
import 'feed.dart';

class FeedController extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
  final Color color;
  FeedController(this.color);
}

class _FeedState extends State<FeedController> {
  
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];



 @override
 Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feed'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Do'),
              Tab(text: 'Fund'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: //FeedView('Do', HexColor('A3D165'))
        TabBarView(children: [
          FeedView("Do", HexColor('A3D165')),
          FeedView("Fund", HexColor('D3C939')),
          FeedView("Done", HexColor('EB8258')),
        ]),
      ),
    );
 }
}

List<FeedView> feeds = <FeedView>[
  FeedView("Do", HexColor('A3D165')),
  FeedView("Fund", HexColor('D3C939')),
  FeedView("Done", HexColor('EB8258')),
];



class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}