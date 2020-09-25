import 'package:flutter/material.dart';
//import 'package:fundder/feed_controller.dart';
import 'placeholder_widget.dart';
import 'feed_controller.dart';
import 'search/search_controller.dart';
import 'liked_controller.dart';
import 'profile_screens/profile_controller.dart';
import 'post_creation_widgets/add_post_controller.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database.dart';
import 'connection_listener.dart';
import 'tutorial_screens/profile_tutorial.dart';
import 'models/user.dart';
import 'shared/loading.dart';
import 'auth_screens/terms_of_use.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screens/terms_of_use_prompted.dart';

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
  bool checkedProfileTutorial = false;
  bool havePresentedWelcome = false;
  bool loadingWelcome = false;

  @override
  void initState() {
    super.initState();
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
        var data = message['data'];
        if (data['type'] == 'Chat') {
          Navigator.pushNamed(context,
              '/chatroom/' + data['senderUid'] + '/' + data['senderUsername']);
        }
        print('onLaunch called');
      },
      onResume: (Map<String, dynamic> message) {
        var data = message['data'];
        if (data['type'] == 'Chat') {
          Navigator.pushNamed(context,
              '/chatroom/' + data['senderUid'] + '/' + data['senderUsername']);
        }
        print('onResume called');
      },
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called');
        var data = message['data'];
        if (data['type'] == 'Chat') {
        } else if (mounted) {
          setState(() {
            if (_currentIndex != 3) {
              unreadNotifs = true;
            }
          });
        }
      },
    );
  }

  // checks if user has any notifications and if they have set their profile pic yet
  void _checkNotifs() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await user.reload();
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
          if (mounted)
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
    print('Checking if introed');
    Firestore.instance
        .collection("users")
        .document(user.uid)
        .get()
        .then((snapshot) async {
      loadingWelcome = false;
      if (snapshot.data['termsAccepted'] == null ||
          snapshot.data['termsAccepted'] == false) {
        bool termsAccepted = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => TermsViewPrompter()));
        if (termsAccepted == true) {
          await Firestore.instance
              .collection('users')
              .document(user.uid)
              .updateData({
            'termsAccepted': true,
          });
        } else {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          await _auth.signOut();
          return;
        }
      }
      if (snapshot != null &&
          (user.isEmailVerified == true) &&
          havePresentedWelcome == false) {
        if (snapshot['name'] == null ||
            snapshot['username'] == null ||
            snapshot['name'] == '' ||
            snapshot['username'] == '' ||
            snapshot['dpSetterPrompted'] == null ||
            snapshot['dpSetterPrompted'] == false) {
          havePresentedWelcome = true;
          print('Pushing add profile pic');
          Navigator.pushNamed(context, '/' + user.uid + '/addProfilePic').then(
              (value) => Firestore.instance
                      .collection('users')
                      .document(user.uid)
                      .updateData({
                    'dpSetterPrompted': true,
                  }));
        }
      }
      if (user.isEmailVerified == false && havePresentedWelcome == false) {
        havePresentedWelcome = true;
        Navigator.pushNamed(context, '/' + user.uid + '/verification')
            .then((value) {
          if (value == true) {
            Navigator.pushNamed(context, '/' + user.uid + '/addProfilePic')
                .then((val) => Firestore.instance
                        .collection('users')
                        .document(user.uid)
                        .updateData({
                      'dpSetterPrompted': true,
                    }));
          }
        });
      }
    });
  }

  void checkProfileTutorial() async {
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((snapshot) {
      if (snapshot != null) {
        if (snapshot['profileTutorialSeen'] != null) {
          if (snapshot['profileTutorialSeen'] != true) {
            _showProfileTutorial(context);
          }
        } else {
          _showProfileTutorial(context);
        }
      }
    });
  }

  Future<void> _showProfileTutorial(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ProfileTutorial();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User>(context);

    return StreamBuilder(
        stream:
            DatabaseService(uid: firebaseUser.uid).userStream(firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DocumentSnapshot doc = snapshot.data;
            if (doc.data != null) {
              if (doc.data['termsAccepted'] == null ||
                  doc.data['termsAccepted'] == false ||
                  doc.data['dpSetterPrompted'] == null ||
                  doc.data['name'] == null ||
                  doc.data['username'] == null ||
                  doc.data['dpSetterPrompted'] == false ||
                  doc.data['name'] == '' ||
                  doc.data['username'] == '') {
                if (havePresentedWelcome == false && loadingWelcome == false) {
                  loadingWelcome = true;
                  _checkIfIntroed();
                }
                return Loading();
              } else {
                User user = DatabaseService(uid: firebaseUser.uid)
                    .userDataFromSnapshot(doc);
                print(user.toString());
                final List<Widget> screens = [
                  FeedController(
                      doTutorialSeen: user.doTutorialSeen,
                      fundTutorialSeen: user.fundTutorialSeen,
                      doneTutorialSeen: user
                          .doneTutorialSeen), //i.e. the one from home button
                  SearchController(),
                  PlaceholderWidget(Colors.white),
                  LikedController(),
                  ProfileController(
                    user: user,
                  ),
                ];
                return Scaffold(
                  body: Column(children: [
                    Expanded(
                        child: IndexedStack(
                      index: _currentIndex,
                      children: screens,
                    )),
                    ConnectionListener()
                  ]), // new : in the body, load the child widget depending on the current index, which is determined by which button is clicked in the bottomNavBar
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Color.fromRGBO(
                        0, 0, 0, 0.5), //hexcolor method is custom at bottom
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
                          unreadNotifs == false
                              ? AntDesign.hearto
                              : AntDesign.heart,
                          color:
                              unreadNotifs == false ? null : HexColor('ff6b6c'),
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
            } else {
              return Loading();
            }
          } else {
            loadingWelcome = true;
            _checkIfIntroed();
            return Loading();
          }
        });
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
    if (index == 4 && checkedProfileTutorial == false) {
      checkProfileTutorial();
      checkedProfileTutorial = true;
    }
    if (index != 2) {
      if (mounted)
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
