// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'do_challenge.dart';
import 'models/user.dart';
import 'feed_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tutorial_screens/tutorial_screen_controller.dart';

class FeedController extends StatefulWidget {
  @override
  _FeedControllerState createState() => _FeedControllerState();
}

class _FeedControllerState extends State<FeedController>
    with SingleTickerProviderStateMixin {
  bool checkedTutorial = false;
  User user;
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 1);
    super.initState();
  }

  void checkTutorial() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((snapshot) {
      if (snapshot != null) {
        if (snapshot['fundTutorialSeen'] != null) {
          if (snapshot['fundTutorialSeen'] != true) {
            _showFundTutorial(context);
          }
        } else {
          _showFundTutorial(context);
        }
      }
    });
  }

  Future<void> _showFundTutorial(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return TutorialScreenController();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('feed controller instantiated');
    if (checkedTutorial == false) {
      checkTutorial();
      checkedTutorial = true;
    }
    final user = Provider.of<User>(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feed'),
          bottom: TabBar(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            //indicatorColor: HexColor(colors[_tabController.index]),
            tabs: [
              Tab(text: 'Do'),
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
