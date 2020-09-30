import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/shared/loading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'find_friends_widgets/link_facebook.dart';
import 'find_friends_widgets/friends_list.dart';

class FindFriends extends StatefulWidget {
  @override
  _FindFriendsState createState() => _FindFriendsState();
}

class _FindFriendsState extends State<FindFriends> {
  bool needToLink = false;
  bool promptNewLogin = false;
  List<String> facebookFriends;
  bool haveRetrievedFriends = false;
  String facebookToken;

  void _loggedIn() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User>(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Follow your friends'),
          leading: Container(),
          actions: [
            FlatButton(
              child:
                  Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: FutureBuilder(
            future: DatabaseService(uid: firebaseUser.uid).readUserData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('Snapshot has data');
                User doc = snapshot.data;
                if (snapshot != null) {
                  // check if facebook id exists
                  if (doc.facebookId == null) {
                    // if not then we prompt to link account to facebook
                    return LinkFacebook(
                      loggedIn: _loggedIn,
                    );
                  } else {
                    // if yes then we need to retrieve the friends list
                    return FriendsList(
                      facebookToken: doc.facebookToken,
                      uid: firebaseUser.uid,
                    );
                  }
                } else {
                  return Loading();
                }
              } else {
                return Loading();
              }
            }));
  }
}
