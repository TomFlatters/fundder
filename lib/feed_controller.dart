// Feed controller controls which feed is shown in the view and general layout of screen.
// feed.dart controls the actual feed content

import 'package:flutter/material.dart';
import 'package:fundder/tutorial_screens/fund_tutorial.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fundder/helper_classes.dart';
import 'package:fundder/messaging/chat_lobby.dart';

import 'package:provider/provider.dart';
import 'do_challenge.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'models/user.dart';
import 'feed_wrapper.dart';

import 'tutorial_screens/fund_tutorial.dart';
import 'tutorial_screens/done_tutorial.dart';
import 'tutorial_screens/do_tutorial.dart';

import 'routes/FadeTransition.dart';

class FeedController extends StatefulWidget {
  final bool doTutorialSeen;
  final bool fundTutorialSeen;
  final bool doneTutorialSeen;
  FeedController(
      {@required this.doTutorialSeen,
      @required this.fundTutorialSeen,
      @required this.doneTutorialSeen});

  @override
  _FeedControllerState createState() => _FeedControllerState();
}

class _FeedControllerState extends State<FeedController>
    with SingleTickerProviderStateMixin {
  User user;
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkTutorials();
    });
    super.initState();
  }

  void _checkTutorials() async {
    if (widget.doTutorialSeen != true && _tabController.index == 0) {
      _showDoTutorial(context);
    }
    if (widget.fundTutorialSeen != true && _tabController.index == 1) {
      _showFundTutorial(context);
    }
    if (widget.doneTutorialSeen != true && _tabController.index == 2) {
      _showDoneTutorial(context);
    }
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

  Future<void> _showDoneTutorial(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DoneTutorial();
      },
    );
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
    _checkTutorials();
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
          title: Text(
            'Fundder',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          leading: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/challengefriend');
              },
              child: new Icon(MdiIcons.sword)),
          actions: [
            MessagingIcon(user.uid),
          ],
          bottom: TabBar(
            onTap: _onItemTapped,
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            //indicatorColor: HexColor(colors[_tabController.index]),
            tabs: [
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Icon(Icons.lightbulb_outline, size: 16)),
                    Text("Challenge")
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Icon(Icons.local_play, size: 16)),
                    Text(
                      " Fund",
                    )
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Icon(Icons.local_movies, size: 16)),
                    Text(" Done")
                  ])),
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ChatLobby()));
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatLobby()));
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
