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

class FindFriends extends StatefulWidget {
  @override
  _FindFriendsState createState() => _FindFriendsState();
}

class _FindFriendsState extends State<FindFriends> {
  bool needToLink = false;
  bool promptNewLogin = false;
  List<String> facebookFriends;

  String facebookToken;

  @override
  void initState() {
    super.initState();
  }

  void _retrieveFriends(String facebookToken) async {
    final friendsGraphResponse = await http.get(
        'https://graph.facebook.com/v8.0/me/friends?access_token=$facebookToken');
    final friends = json.decode(friendsGraphResponse.body);
    List friendMaps = friends['data'];
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User>(context);

    return StreamBuilder(
        stream:
            DatabaseService(uid: firebaseUser.uid).userStream(firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('Snapshot has data');
            DocumentSnapshot doc = snapshot.data;
            if (snapshot != null) {
              if (doc.data['facebookId'] == null) {
                return LinkFacebook();
              } else {}
            } else {
              return Loading();
            }
          } else {
            return Loading();
          }
        });
  }
}
