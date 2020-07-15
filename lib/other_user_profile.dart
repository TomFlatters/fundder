import 'package:flutter/material.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';
import 'feed.dart';
import 'edit_profile_controller.dart';
import 'models/user.dart';
import 'view_followers_controller.dart';
import 'helper_classes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewUser extends StatefulWidget {
  @override
  _ViewUserState createState() => _ViewUserState();

  final String uid;
  ViewUser({this.uid});
}

class _ViewUserState extends State<ViewUser>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  String _username = "Username";
  String _name = "Name";
  String _uid;
  String _email = "Email";
  String _profilePic =
      'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _retrieveUser();
    super.initState();
  }

  void _retrieveUser() async {
    //var firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(widget.uid)
        .get()
        .then((value) {
      setState(() {
        _uid = widget.uid;
        _name = value.data["name"];
        _username = widget.uid;
        _profilePic = value.data["profilePic"];
        if (_profilePic == null) {
          _profilePic =
              'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
          DatabaseService(uid: _uid)
              .updateUserData(_email, _username, _name, _profilePic);
        }
      });
    });
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
        future: DatabaseService(uid: widget.uid).readUserData(),
        builder: (BuildContext context, AsyncSnapshot<User> userData) {
          print(userData);
          if (userData.connectionState == ConnectionState.waiting) {
            return Loading();
          } else {
            if (userData.hasError)
              return Center(child: Text('Error: ${userData.error}'));
            else
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(_username),
                  actions: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(null),
                    )
                  ],
                  leading: new Container(),
                ),
                body: ListView(shrinkWrap: true, children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 10),
                    alignment: Alignment.center,
                    child: Container(
                      child: ProfilePicFromUrl(_profilePic, 90),
                      margin: EdgeInsets.all(10.0),
                    ),
                  ),
                  Center(
                    child: Text(_username),
                  ),
                  Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      height: 50,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: GestureDetector(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Text("54",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Expanded(
                                    child: Container(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Following"),
                                )),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context,
                                  '/user/' + widget.uid + '/followers');
                            },
                          )),
                          Expanded(
                              child: GestureDetector(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Text("106",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Expanded(
                                    child: Container(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Followers"),
                                )),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context,
                                  '/user/' + widget.uid + '/followers');
                            },
                          )),
                          Expanded(
                              child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                child: Text("£54",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.bottomCenter,
                                child: Text("Raised"),
                              )),
                            ],
                          )),
                        ],
                      )),
                  GestureDetector(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        margin:
                            EdgeInsets.only(left: 70, right: 70, bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Text(
                          "Follow",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      onTap: () {}),
                  DefaultTabController(
                    length: 1,
                    initialIndex: 0,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [Tab(text: 'Posts') /*, Tab(text: 'Liked')*/],
                          controller: _tabController,
                        ),
                        [
                          FeedView(
                              'user',
                              'adrikoz',
                              Colors.black,
                              DatabaseService(uid: widget.uid)
                                  .postsByUser(widget.uid)),
                          FeedView(
                              'user',
                              'adrikoz',
                              Colors.blue,
                              DatabaseService(uid: widget.uid)
                                  .postsByUser(widget.uid)),
                        ][_tabController.index]
                      ],
                    ),
                  )
                ]),
              );
          }
        });
  }
}
