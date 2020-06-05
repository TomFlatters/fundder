// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:flutter/material.dart';
import 'feed.dart';
import 'helper_classes.dart';

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