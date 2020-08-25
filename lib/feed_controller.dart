// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:flutter/material.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
import 'feed.dart';
import 'helper_classes.dart';
import 'do_challenge.dart';
import 'models/user.dart';
import 'push_notifications.dart';
import 'feed_wrapper.dart';

class FeedController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('feed controller instantiated');
    final user = Provider.of<User>(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feed'),
          bottom: TabBar(
            //indicatorColor: HexColor(colors[_tabController.index]),
            tabs: [
              Tab(text: 'Do'),
              Tab(text: 'Fund'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: //FeedView('Do', HexColor('ff6b6c'))
            TabBarView(children: [
          DoChallenge(user),
          FeedWrapper("Fund", null, "fund"),
          FeedWrapper("Done", null, "done"),
        ]),
      ),
    );
  }
}
