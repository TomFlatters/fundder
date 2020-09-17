// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:flutter/material.dart';
import 'package:fundder/messaging/chat_lobby.dart';
import 'package:provider/provider.dart';
import 'do_challenge.dart';

import 'models/user.dart';
import 'feed_wrapper.dart';
import 'routes/FadeTransition.dart';

class FeedController extends StatefulWidget {
  @override
  _FeedControllerState createState() => _FeedControllerState();
}

class _FeedControllerState extends State<FeedController>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('feed controller instantiated');
    final user = Provider.of<User>(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feed'),
          actions: [
            IconButton(
                icon: Icon(Icons.chat_bubble_rounded),
                onPressed: () {
                  Navigator.push(context, FadeRoute(page: ChatLobby()));
                })
          ],
          bottom: TabBar(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            //indicatorColor: HexColor(colors[_tabController.index]),
            tabs: [
              Tab(text: 'Ideas'),
              Tab(text: 'Fund'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: //FeedView('Do', HexColor('ff6b6c'))
            TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
              DoChallenge(user),
              FeedWrapper("Fund", null, "fund"),
              FeedWrapper("Done", null, "done"),
            ]),
      ),
    );
  }
}
