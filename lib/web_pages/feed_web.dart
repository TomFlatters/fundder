import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'web_menu.dart';
import 'package:fundder/feed.dart';
import 'package:fundder/do_challenge.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/feed_wrapper.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

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
    initDynamicLinks();
    super.initState();
  }

  void initDynamicLinks() async {
    print('init dynamic links');
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleLinkData(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData dynamicLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (dynamicLink != null) {
      handleLinkData(dynamicLink);
    } else {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      if (user == null) {
        Navigator.pushNamed(context, '/web/login');
      }
    }
  }

  void handleLinkData(PendingDynamicLinkData data) async {
    final Uri uri = data?.link;
    print("uri: " + uri.toString());
    if (uri != null) {
      final queryParams = uri.queryParameters;
      if (queryParams.length > 0 && queryParams['post'] != null) {
        String post = queryParams["post"];
        print("pushing " + post);
        Navigator.pushNamed(context, "/post/" + post);
        // verify the username is parsed correctly

      }
    } else {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      if (user == null) {
        Navigator.pushNamed(context, '/web/login');
      }
    }
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
      //Future.microtask(() => Navigator.pushNamed(context, '/web/login'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Sohne',
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
                              DoChallenge(user),
                              FeedWrapper("Fund", null, "fund"),
                              FeedWrapper("Done", null, "done"),
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
