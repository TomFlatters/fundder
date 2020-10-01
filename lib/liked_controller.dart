import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'helper_classes.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'global_widgets/follow_request_tile.dart';

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
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          centerTitle: true,
          title: Text('Activity'),
        ),
        body: SmartRefresher(
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
            child: ListView(children: [
              StreamBuilder(
                  stream: followRequests,
                  builder: (context, snapshot) {
                    // print(snapshot.data);
                    if (!snapshot.hasData) {
                      return SizedBox(
                        height: 0,
                      );
                    } else {
                      DocumentSnapshot doc = snapshot.data;
                      List requestedToFollowMe =
                          doc.data['requestedToFollowMe'];
                      print('requested to follow me: ' +
                          requestedToFollowMe.toString());
                      if (requestedToFollowMe != null &&
                          requestedToFollowMe != [] &&
                          requestedToFollowMe.isNotEmpty) {
                        print('building column');
                        return Container(
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.all(
                                  Radius.circular(10.0),
                                )),
                            margin: EdgeInsets.only(top: 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      'Follow Requests:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  ListView.builder(
                                      padding: EdgeInsets.only(bottom: 10),
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: requestedToFollowMe.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return FollowRequestTile(
                                            currentUserUid: user.uid,
                                            displayUserUid:
                                                requestedToFollowMe[index]);
                                      })
                                ]));
                      } else {
                        return SizedBox(
                          height: 0,
                        );
                      }
                    }
                  }),
              StreamBuilder(
                  stream: activityItems,
                  builder: (context, snapshot) {
                    // print(snapshot.data);
                    if (!snapshot.hasData) {
                      return Text("No data...");
                    } else {
                      return Container(
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.all(
                                Radius.circular(10.0),
                              )),
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Activity:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                ListView.builder(
                                    padding: EdgeInsets.only(bottom: 10),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.length != 0
                                        ? snapshot.data.length
                                        : 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (snapshot.data.length == 0) {
                                        return Center(
                                          child: Container(
                                              constraints: BoxConstraints(
                                                  minHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height -
                                                          80),
                                              decoration: new BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      new BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  )),
                                              padding:
                                                  EdgeInsets.only(top: 150),
                                              child: Column(children: [
                                                Icon(
                                                  AntDesign.profile,
                                                  color: Colors.grey,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width /
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Founders Grotesk'),
                                                    )),
                                              ])),
                                        );
                                      } else {
                                        DocumentSnapshot likedItem =
                                            snapshot.data[index];
                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  '/user/' +
                                                      likedItem['docLiker']);
                                            },
                                            child: Container(
                                                decoration: new BoxDecoration(
                                                  color:
                                                      likedItem['seen'] == false
                                                          ? Colors.grey[100]
                                                          : Colors.white,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0.0),
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 3),
                                                    child: Column(
                                                        children: <Widget>[
                                                          Container(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minHeight:
                                                                        60),
                                                            child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          GestureDetector(
                                                                        child:
                                                                            Container(
                                                                          child: ProfilePic(
                                                                              likedItem['docLiker'],
                                                                              40),
                                                                          margin:
                                                                              EdgeInsets.all(10.0),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/user/' + likedItem['docLiker']);
                                                                        },
                                                                      )),
                                                                  Expanded(
                                                                      child: Align(
                                                                          alignment: Alignment.centerLeft,
                                                                          child: RichText(
                                                                              text: TextSpan(
                                                                                  style: TextStyle(
                                                                                    fontSize: 16.0,
                                                                                    color: Colors.black,
                                                                                    fontFamily: 'Founders Grotesk',
                                                                                  ),
                                                                                  children: [
                                                                                TextSpan(text: likedItem['docLikerUsername'] != null ? likedItem['docLikerUsername'] + " " : "", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                _itemText(likedItem),
                                                                              ])))),
                                                                  Container(
                                                                      width:
                                                                          110,
                                                                      child: Align(
                                                                          alignment: Alignment.centerRight,
                                                                          child: GestureDetector(
                                                                            child:
                                                                                Container(
                                                                              width: 110,
                                                                              padding: EdgeInsets.only(top: 7, bottom: 3, left: 5, right: 5),
                                                                              margin: EdgeInsets.all(10),
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: Colors.grey, width: 1),
                                                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                              ),
                                                                              child: Text(
                                                                                likedItem['category'] == 'new follower' || likedItem['category'] == 'new facebook friend' || likedItem['category'] == 'request accepted' ? "View User" : "View Post",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 14,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap:
                                                                                () {
                                                                              Firestore.instance.collection('users').document(uid).collection('activity').where('postId', isEqualTo: likedItem['postId']).getDocuments().then((response) => {
                                                                                    if (response != null)
                                                                                      {
                                                                                        _batchUpdate(response)
                                                                                      }
                                                                                  });
                                                                              if (likedItem['category'] == 'new follower' || likedItem['category'] == 'new facebook friend' || likedItem['category'] == 'request accepted') {
                                                                                Navigator.pushNamed(context, '/user/' + likedItem['postId']);
                                                                              } else {
                                                                                Navigator.pushNamed(context, '/post/' + likedItem['postId']);
                                                                              }
                                                                            },
                                                                          ))),
                                                                ]),
                                                          )
                                                        ]))));
                                      }
                                    })
                              ]));
                    }
                  })
            ])));
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

      case 'new facebook friend':
        return TextSpan(text: 'who is your facebook friend, is on Fundder');

      case 'request accepted':
        return TextSpan(text: 'has accepted your follow request');

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

  Stream<DocumentSnapshot> get followRequests {
    return Firestore.instance.collection('followers').document(uid).snapshots();
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
