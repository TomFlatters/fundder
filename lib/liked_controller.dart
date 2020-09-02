import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'helper_classes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_icons/flutter_icons.dart';

class LikedController extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
  LikedController();
}

class _ActivityState extends State<LikedController> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<List<DocumentSnapshot>> postList;
  String uid;
  User user;
  int limit = 20;
  Timestamp loadingTimestamp;

  void _onRefresh() {
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    //_getCurrentUser();
  }

  /*_getCurrentUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid;
  }*/

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    uid = user.uid;
    if (user == null && kIsWeb == true) {
      Future.microtask(() => Navigator.pushNamed(context, '/web/login'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Founders Grotesk',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
      return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: kIsWeb == true
              ? null
              : AppBar(
                  centerTitle: true,
                  title: Text('Activity'),
                ),
          body: new StreamBuilder(
              stream: activityItems,
              builder: (context, snapshot) {
                // print(snapshot.data);
                if (!snapshot.hasData) {
                  return Text("No data...");
                } else {
                  return SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: false,
                      header: CustomHeader(
                        builder: (BuildContext context, RefreshStatus mode) {
                          return Container(
                            height: 55.0,
                            child: Center(child: Text('Updates automatically')),
                          );
                        },
                      ),
                      controller: _refreshController,
                      onRefresh: () {
                        _onRefresh();
                      },
                      child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              color: Colors.grey,
                              height: 0,
                              thickness: 0.3,
                              indent: 20,
                              endIndent: 0,
                            );
                          },
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          shrinkWrap: true,
                          itemCount: snapshot.data.length != 0
                              ? snapshot.data.length
                              : 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (snapshot.data.length == 0) {
                              return Center(
                                child: Container(
                                    constraints: BoxConstraints(
                                        minHeight:
                                            MediaQuery.of(context).size.height -
                                                80),
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: new BorderRadius.all(
                                          Radius.circular(10.0),
                                        )),
                                    padding: EdgeInsets.only(top: 150),
                                    child: Column(children: [
                                      Icon(
                                        AntDesign.profile,
                                        color: Colors.grey,
                                        size:
                                            MediaQuery.of(context).size.width /
                                                8,
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: 30,
                                              left: 40,
                                              right: 40,
                                              bottom: 150),
                                          child: Text(
                                            'This is where you see your notifications. Create a Fundder challenge to raise for a cause or follow users to be alerted when they post.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                fontFamily: 'Founders Grotesk'),
                                          )),
                                    ])),
                              );
                            } else {
                              DocumentSnapshot likedItem = snapshot.data[index];
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        '/user/' + likedItem['docLiker']);
                                  },
                                  child: Container(
                                      decoration: new BoxDecoration(
                                        color: likedItem['seen'] == false
                                            ? Colors.grey[100]
                                            : Colors.white,
                                        borderRadius: index == 0
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              )
                                            : index == snapshot.data.length - 1
                                                ? BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10.0),
                                                    bottomRight:
                                                        Radius.circular(10.0),
                                                  )
                                                : BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(0.0),
                                                    bottomRight:
                                                        Radius.circular(0.0),
                                                  ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0),
                                      child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(children: <Widget>[
                                            Container(
                                              height: 60,
                                              child: Row(children: <Widget>[
                                                Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: GestureDetector(
                                                      child: AspectRatio(
                                                          aspectRatio: 1 / 1,
                                                          child: Container(
                                                            child: ProfilePic(
                                                                likedItem[
                                                                    'docLiker'],
                                                                40),
                                                            margin:
                                                                EdgeInsets.all(
                                                                    10.0),
                                                          )),
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/user/' +
                                                                likedItem[
                                                                    'docLiker']);
                                                      },
                                                    )),
                                                Expanded(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: RichText(
                                                            text: TextSpan(
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'Founders Grotesk',
                                                                ),
                                                                children: [
                                                              TextSpan(
                                                                  text: likedItem[
                                                                          'docLikerUsername'] +
                                                                      " ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              _itemText(
                                                                  likedItem),
                                                            ])))),
                                                Container(
                                                    width: 110,
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: GestureDetector(
                                                          child: Container(
                                                            width: 110,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        5),
                                                            margin:
                                                                EdgeInsets.all(
                                                                    10),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              5)),
                                                            ),
                                                            child: Text(
                                                              likedItem['category'] ==
                                                                      'new follower'
                                                                  ? "View User"
                                                                  : "View Post",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            Firestore.instance
                                                                .collection(
                                                                    'users')
                                                                .document(uid)
                                                                .collection(
                                                                    'activity')
                                                                .where('postId',
                                                                    isEqualTo:
                                                                        likedItem[
                                                                            'postId'])
                                                                .getDocuments()
                                                                .then(
                                                                    (response) =>
                                                                        {
                                                                          if (response !=
                                                                              null)
                                                                            {
                                                                              _batchUpdate(response)
                                                                            }
                                                                        });
                                                            if (likedItem[
                                                                    'category'] ==
                                                                'new follower') {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/user/' +
                                                                      likedItem[
                                                                          'postId']);
                                                            } else {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/post/' +
                                                                      likedItem[
                                                                          'postId']);
                                                            }
                                                          },
                                                        ))),
                                              ]),
                                            )
                                          ]))));
                            }
                          }));
                }
              }));
    }
  }

  TextSpan _itemText(DocumentSnapshot likedItem) {
    switch (likedItem['category']) {
      case 'like':
        return TextSpan(text: 'liked your post');

      case 'comment':
        return TextSpan(text: 'commented on your post');

      case 'donate':
        return TextSpan(text: 'donated to your challenge');

      case 'post completed':
        return TextSpan(text: 'completed a challenge that you like');

      case 'post donated to completed':
        return TextSpan(text: 'completed a challenge that you donated to');

      case 'new post from following':
        return TextSpan(text: 'who you follow, has posted');

      case 'new follower':
        return TextSpan(text: 'has started following you');

      default:
        return TextSpan(text: 'has done an action');
    }
  }

  _batchUpdate(QuerySnapshot response) {
    response.documents.forEach((msgDoc) {
      msgDoc.reference.updateData({'seen': true});
    });
  }

  Stream<List<DocumentSnapshot>> get activityItems {
    return Firestore.instance
        .collection('users')
        .document(uid)
        .collection('activity')
        .orderBy("seen", descending: false)
        .orderBy("timestamp", descending: true)
        .limit(30)
        .snapshots()
        .map(_activityItemsFromSnapshot);
  }

  List<DocumentSnapshot> _activityItemsFromSnapshot(QuerySnapshot snapshot) {
    print('mapping the posts to Post model');
    return snapshot.documents.map((DocumentSnapshot doc) {
      return doc;
    }).toList();
  }
}

/*void _onRefresh() async {
    // monitor network fetch
    loadingTimestamp = Timestamp.now();
    List<DocumentSnapshot> futureActivity = await refreshActivity();
    if (futureActivity != null) {
      if (futureActivity.isEmpty == false) {
        DocumentSnapshot lastActivity = futureActivity.last;
        print('postList' + postList.toString());
        loadingTimestamp = lastActivity['timestamp'];
        postList = [futureActivity];
      }
    }
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch

    List<DocumentSnapshot> futureActivity = await refreshActivity();
    if (futureActivity != null) {
      if (futureActivity.isEmpty == false) {
        postList.add(futureActivity);
        DocumentSnapshot lastActivity = futureActivity.last;
        loadingTimestamp = lastActivity['timestamp'];
      }
    }
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  Future<List<DocumentSnapshot>> refreshActivity() {
    print('limit: ' + limit.toString());
    return Firestore.instance
        .collection('users')
        .document(uid)
        .collection('activity')
        .orderBy("timestamp", descending: true)
        .startAfter([loadingTimestamp])
        .limit(limit)
        .getDocuments()
        .then((snapshot) {
          return snapshot.documents.map((DocumentSnapshot doc) {
            return doc;
          }).toList();
        });
  }

  final List<String> entries = <String>[
    'started following you',
    'liked your post',
    'donated to your fundraiser'
  ];
  final List<String> buttons = <String>['Follow back', 'View', 'View'];*/
