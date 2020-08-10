import 'package:flutter/material.dart';
//import 'package:fundder/feed_controller.dart';
import 'placeholder_widget.dart';
import 'feed_controller.dart';
import 'search/search_controller.dart';
import 'liked_controller.dart';
import 'profile_controller.dart';
import 'add_post_controller.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool unreadNotifs = false;

  @override
  void initState() {
    super.initState();
    _checkIfIntroed();
    _checkNotifs();
    var fcmTokenStream = _firebaseMessaging.onTokenRefresh;
    fcmTokenStream.listen((token) async {
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      // this will get called on logging out otherwise and throw errors
      if (user != null) {
        DatabaseService(uid: user.uid).addFCMToken(token);
      }
    });
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch called');
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume called');
      },
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called');
        setState(() {
          if (_currentIndex != 3) {
            unreadNotifs = true;
          }
        });
      },
    );
  }

  // checks if user has any notifications and if they have set their profile pic yet
  void _checkNotifs() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(user.uid)
        .collection("activity")
        .where("seen", isEqualTo: false)
        .limit(1)
        .getDocuments()
        .then((snapshot) {
      if (snapshot != null) {
        if (snapshot.documents.isEmpty == false) {
          setState(() {
            unreadNotifs = true;
          });
        }
      }
    });
  }

  void _checkIfIntroed() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await user.reload();
    Firestore.instance
        .collection("users")
        .document(user.uid)
        .get()
        .then((snapshot) {
      if (snapshot != null && user.isEmailVerified == true) {
        if (snapshot['dpSetterPrompted'] != null) {
          if (snapshot['dpSetterPrompted'] != true) {
            Navigator.pushNamed(context, '/' + user.uid + '/addProfilePic');
          }
        } else {
          Navigator.pushNamed(context, '/' + user.uid + '/addProfilePic');
        }
        if (snapshot['seenTutorial'] != null) {
          if (snapshot['seenTutorial'] != true) {
            Navigator.pushNamed(context, '/' + user.uid + '/tutorial');
          }
        } else {
          Navigator.pushNamed(context, '/' + user.uid + '/tutorial');
        }
      }
      if (user.isEmailVerified == false) {
        Navigator.pushNamed(context, '/' + user.uid + '/verification');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final List<Widget> screens = [
      FeedController(), //i.e. the one from home button
      SearchController(),
      PlaceholderWidget(Colors.white),
      LikedController(),
      ProfileController(
        uid: user.uid,
      )
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ), // new : in the body, load the child widget depending on the current index, which is determined by which button is clicked in the bottomNavBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor:
            Color.fromRGBO(0, 0, 0, 0.5), //hexcolor method is custom at bottom
        iconSize: 26,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.home,
            ),
            title: showIndicator(_currentIndex == 0),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.search1,
            ),
            title: showIndicator(_currentIndex == 1),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.plussquareo,
            ),
            title: showIndicator(_currentIndex == 2),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              unreadNotifs == false ? AntDesign.hearto : AntDesign.heart,
              color: unreadNotifs == false ? null : HexColor('ff6b6c'),
            ),
            title: showIndicator(_currentIndex == 3),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.user,
            ),
            title: showIndicator(_currentIndex == 4),
          )
        ],
      ),
    );
  }

  Widget showIndicator(bool show) {
    return show
        ? Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 0),
            child: Icon(Icons.brightness_1, size: 4, color: Colors.black),
          )
        : SizedBox(height: 8);
  }

  void onTabTapped(int index) {
    if (index != 2) {
      setState(() {
        _currentIndex = index;
        if (index == 3) {
          unreadNotifs = false;
        }
      });
    } else {
      Navigator.pushNamed(context, '/addpost');
    }
  }
}
