// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fundder/tutorial_screens/fund_tutorial.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fundder/helper_classes.dart';
import 'package:fundder/messaging/chat_lobby.dart';

import 'package:provider/provider.dart';
import 'do_challenge.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'models/user.dart';
import 'feed_wrapper.dart';

import 'tutorial_screens/fund_tutorial.dart';
import 'tutorial_screens/done_tutorial.dart';
import 'tutorial_screens/do_tutorial.dart';

import 'routes/FadeTransition.dart';

class FeedController extends StatefulWidget {
  @override
  _FeedControllerState createState() => _FeedControllerState();
}

class _FeedControllerState extends State<FeedController>
    with SingleTickerProviderStateMixin {
  bool checkedDoTutorial = false;
  bool checkedFundTutorial = false;
  bool checkedDoneTutorial = false;
  User user;
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 1);
    super.initState();
  }

  void checkFundTutorial(User firebaseUser) async {
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
        return FundTutorial();
      },
    );
  }

  void checkDoneTutorial(User firebaseUser) async {
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((snapshot) {
      if (snapshot != null) {
        if (snapshot['doneTutorialSeen'] != null) {
          if (snapshot['doneTutorialSeen'] != true) {
            _showDoneTutorial(context);
          }
        } else {
          _showDoneTutorial(context);
        }
      }
    });
  }

  Future<void> _showDoneTutorial(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DoneTutorial();
      },
    );
  }

  void checkDoTutorial(User firebaseUser) async {
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((snapshot) {
      if (snapshot != null) {
        if (snapshot['doTutorialSeen'] != null) {
          if (snapshot['doTutorialSeen'] != true) {
            _showDoTutorial(context);
          }
        } else {
          _showDoTutorial(context);
        }
      }
    });
  }

  Future<void> _showDoTutorial(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DoTutorial();
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('feed controller instantiated');
    final user = Provider.of<User>(context);
    if (checkedDoTutorial == false && _tabController.index == 0) {
      checkDoTutorial(user);
      checkedDoTutorial = true;
    }
    if (checkedFundTutorial == false && _tabController.index == 1) {
      checkFundTutorial(user);
      checkedFundTutorial = true;
    }
    if (checkedDoneTutorial == false && _tabController.index == 2) {
      checkDoneTutorial(user);
      checkedDoneTutorial = true;
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          centerTitle: true,
          title: Text('Feed'),
          actions: [
            MessagingIcon(user.uid),
          ],
          bottom: TabBar(
            onTap: _onItemTapped,
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

_iconWithDot(context) {
  return Stack(
    children: [
      IconButton(
          icon: Icon(SimpleLineIcons.bubbles),
          onPressed: () {
            Navigator.push(context, FadeRoute(page: ChatLobby()));
          }),
      Positioned(
          top: 10,
          left: 30,
          child: Icon(
            Icons.brightness_1,
            color: HexColor('ff6b6c'),
            size: 9.0,
          )),
    ],
  );
}

_iconWithoutDot(context) {
  return IconButton(
      icon: Icon(SimpleLineIcons.bubbles),
      onPressed: () {
        Navigator.push(context, FadeRoute(page: ChatLobby()));
      });
}

class MessagingIcon extends StatelessWidget {
  final String uid;
  MessagingIcon(this.uid);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userChatStatus')
            .document(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _iconWithoutDot(context);
          } else if (snapshot.data.exists) {
            if (snapshot.data["chatNeedsAttention"] != null) {
              return (snapshot.data["chatNeedsAttention"] == true)
                  ? _iconWithDot(context)
                  : _iconWithoutDot(context);
            } else {
              return _iconWithoutDot(context);
            }
          } else {
            return _iconWithoutDot(context);
          }
        });
  }
}
