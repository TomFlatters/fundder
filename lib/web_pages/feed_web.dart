import 'package:flutter/material.dart';
import 'web_menu.dart';
import 'package:fundder/feed.dart';
import 'package:fundder/do_challenge.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/user.dart';

class WebFeed extends StatefulWidget {
  @override
  _WebFeedState createState() => _WebFeedState();
}

class _WebFeedState extends State<WebFeed> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print('feed web called');
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    if (user == null) {
      Future.microtask(() => Navigator.pushNamed(context, '/web/login'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
      return Scaffold(
        body: Container(
          height: size.height,
          // it will take full width
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              WebMenu(1),
              Expanded(
                  child: Container(
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 400),
                      child: DefaultTabController(
                        length: 3,
                        initialIndex: 0,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: [
                                Tab(text: 'Do'),
                                Tab(text: 'Fund'),
                                Tab(text: 'Done')
                              ],
                              controller: _tabController,
                            ),
                            Expanded(
                                child: [
                              DoChallenge(),
                              FeedView(
                                  UniqueKey(),
                                  "Fund",
                                  null,
                                  HexColor('ff6b6c'),
                                  DatabaseService(uid: user.uid).fundPosts),
                              FeedView(
                                  UniqueKey(),
                                  "Done",
                                  null,
                                  HexColor('ff6b6c'),
                                  DatabaseService(uid: user.uid).donePosts),
                            ][_tabController.index]),
                          ],
                        ),
                      )))
            ],
          ),
        ),
      );
    }
  }
}
