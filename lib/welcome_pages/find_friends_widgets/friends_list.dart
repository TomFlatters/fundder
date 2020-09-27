import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fundder/services/auth.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/profileWidgets/followButton.dart';
import 'package:fundder/global_widgets/auth_button.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/shared/loading.dart';
import 'facebook_friends_follow_button.dart';

class FriendsList extends StatefulWidget {
  final String uid;
  final String facebookToken;
  FriendsList({this.facebookToken, this.uid});
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  bool needToLink = false;
  bool promptNewLogin = false;
  List facebookFriends;
  bool haveRetrievedFriends = false;
  String facebookToken;
  bool loading = false;
  final _auth = AuthService();
  @override
  void initState() {
    _retrieveFriends(widget.facebookToken);
    super.initState();
  }

  void _retrieveFriends(String facebookToken) async {
    final friendsGraphResponse = await http.get(
        'https://graph.facebook.com/v8.0/me/friends?access_token=$facebookToken');
    final friends = json.decode(friendsGraphResponse.body);
    print('friends raw: ' + friends.toString());
    if (friends['error'] != null &&
        friends['error']['type'].toString() == "OAuthException") {
      print('prompt new login');
      setState(() {
        loading = false;
        promptNewLogin = true;
      });
    } else {
      facebookFriends = await _convertFriendsList(friends['data']);
      print('friend maps: ' + facebookFriends.toString());
      setState(() {
        loading = false;
        haveRetrievedFriends = true;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _convertFriendsList(
      List<dynamic> friendsList) async {
    final ids = friendsList.map((dynamic doc) {
      return doc['id'].toString();
    }).toList();

    return await GeneralFollowerServices()
        .facebookFriendsUnames(ids, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    if (haveRetrievedFriends == true) {
      if (facebookFriends == null || facebookFriends.length == 0) {
        return Center(
            child: Container(
                padding: EdgeInsets.all(30),
                child: Text('No facebook friends found')));
      }
      return ListView.builder(
        itemCount: facebookFriends.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                print('/user/' + facebookFriends[index]['uid']);
                Navigator.pushNamed(
                    context, '/user/' + facebookFriends[index]['uid']);
              },
              child: Container(
                  margin: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                  child: Row(children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: ProfilePic(facebookFriends[index]['uid'], 40),
                        margin: EdgeInsets.all(10.0),
                      ),
                    ),
                    Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                facebookFriends[index]['username'].toString(),
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)))),
                    FbFollowButton(widget.uid, facebookFriends[index]['uid'])
                  ])));
        },
      );
    } else {
      if (promptNewLogin == true && loading == false) {
        return Center(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'Your facebook token has expired. Please log in again to find your facebook friends',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18)),
                    SizedBox(height: 25),
                    AuthFundderButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        String result =
                            await _auth.getNewFacebookToken(widget.uid);
                        print(result);

                        if (result.contains('Error')) {
                          setState(() {
                            loading = false;
                          });
                          DialogManager().createDialog(
                              "Link to Facebook", result, context);
                        } else {
                          _retrieveFriends(result);
                          facebookToken = result;
                        }
                      },
                      backgroundColor: HexColor('4267B2'),
                      borderColor: HexColor('4267B2'),
                      textColor: Colors.white,
                      text: 'Log into Facebook',
                      buttonIconData: FontAwesome5Brands.facebook_f,
                      iconColor: Colors.white,
                    ),
                  ])),
        );
      } else {
        return Loading();
      }
    }
  }
}
