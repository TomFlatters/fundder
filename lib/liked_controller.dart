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
              fontFamily: 'Quicksand',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
      return Scaffold(
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
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot likedItem = snapshot.data[index];
                            return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0.0),
                                color: likedItem['seen'] == false
                                    ? Colors.grey[100]
                                    : Colors.white,
                                child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(children: <Widget>[
                                      Container(
                                        height: 60,
                                        child: Row(children: <Widget>[
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: GestureDetector(
                                                child: AspectRatio(
                                                    aspectRatio: 1 / 1,
                                                    child: Container(
                                                      child: ProfilePic(
                                                          likedItem['docLiker'],
                                                          40),
                                                      margin:
                                                          EdgeInsets.all(10.0),
                                                    )),
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, '/username');
                                                },
                                              )),
                                          Expanded(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: RichText(
                                                      text: TextSpan(
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            color: Colors.black,
                                                            fontFamily: 'Muli',
                                                          ),
                                                          children: [
                                                        TextSpan(
                                                            text: likedItem[
                                                                'docLikerUsername'],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text: likedItem[
                                                                        'category'] ==
                                                                    'like'
                                                                ? ' liked your post'
                                                                : likedItem['category'] ==
                                                                        'comment'
                                                                    ? ' commented on your post'
                                                                    : ' has completed a challenge that you liked'),
                                                      ])))),
                                          Container(
                                              width: 110,
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: GestureDetector(
                                                    child: Container(
                                                      width: 110,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 5),
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5)),
                                                      ),
                                                      child: Text(
                                                        "View",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Firestore.instance
                                                          .collection('users')
                                                          .document(uid)
                                                          .collection(
                                                              'activity')
                                                          .where('postId',
                                                              isEqualTo:
                                                                  likedItem[
                                                                      'postId'])
                                                          .where('category',
                                                              isEqualTo:
                                                                  likedItem[
                                                                      'category'])
                                                          .getDocuments()
                                                          .then((response) => {
                                                                if (response !=
                                                                    null)
                                                                  {
                                                                    _batchUpdate(
                                                                        response)
                                                                  }
                                                              });
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/post/' +
                                                              likedItem[
                                                                  'postId']);
                                                    },
                                                  ))),
                                        ]),
                                      )
                                    ])));
                          }));
                }
              }));
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
