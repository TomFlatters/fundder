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

class _FeedState extends State<FeedController> with SingleTickerProviderStateMixin {
  
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<String> colors = <String>['A3D165','D3C939','EB8258'];
  int index = 0;
  //bool colorChanged = true;

  TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      //index = _tabController.index;
      //colorChanged = false;
      setState(() {
        
      });
    }
    print(_tabController.animation.value);
  }

  /*_changeTicker() {
    if (_tabController.animation.value%1>0.7 && colorChanged == false){
      setState(() {});
      colorChanged = true;
    }
    print(_tabController.animation.value);
  }*/



 @override
 Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feed'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: HexColor(colors[_tabController.index]),
            tabs: [
              Tab(text: 'Do'),
              Tab(text: 'Fund'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: //FeedView('Do', HexColor('A3D165'))
        TabBarView(
          controller: _tabController,
          children: [
          FeedView("Do", HexColor(colors[0])),
          FeedView("Fund", HexColor(colors[1])),
          FeedView("Done", HexColor(colors[2])),
        ]),
    );
 }
}