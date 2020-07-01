// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:flutter/material.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
import 'feed.dart';
import 'helper_classes.dart';
import 'do_challenge.dart';
import 'models/user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/menu_item.dart';

class FeedController extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<FeedController>
    with SingleTickerProviderStateMixin {
  final List<String> entries = <String>['A', 'B', 'C'];
  final List<String> colors = <String>['ff6b6c', 'E63946', 'ff6b6c'];
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
      setState(() {});
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
    final user = Provider.of<User>(context);
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
      body: //FeedView('Do', HexColor('ff6b6c'))
          TabBarView(controller: _tabController, children: [
        DoChallenge(),
        FeedView("Fund", null, HexColor(colors[1]),
            DatabaseService(uid: user.uid).posts),
        FeedView("Done", null, HexColor(colors[2]),
            DatabaseService(uid: user.uid).posts),
      ]),
    );
  }
}
