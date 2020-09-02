import 'package:flutter/material.dart';

import 'package:fundder/post_widgets/commentBar.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/post_widgets/shareBar.dart';
import 'package:fundder/services/likes.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'post_widgets/postHeader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/post.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'global_widgets/buttons.dart';
import 'services/database.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:async';

class ViewPost extends StatefulWidget {
  @override
  _ViewPostState createState() => _ViewPostState();

  final Post startPost;
  ViewPost(
    this.startPost,
    /*{this.noLikes, this.hasLiked}*/
  );
}

class _ViewPostState extends State<ViewPost> with RouteAware {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  // int noLikes;
  // bool hasLiked;

  Post postData;
  bool willNeedUpdate = false;

  @override
  void initState() {
    postData = widget.startPost;
    super.initState();
  }

  Container createPostUI(
      Post postData, String uid, context, LikesService likesService) {
    StreamController<void> likesManager = StreamController<int>();
    Stream rebuildLikesButton = likesManager.stream;
    var currLikeButton = createLikesFutureBuilder(likesService, postData, uid);
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 0),
        child: Column(children: <Widget>[
          PostHeader(
              postAuthorId: postData.author,
              postAuthorUserName: postData.authorUsername,
              targetCharity: postData.charity,
              charityLogo: postData.charityLogo),
          PostBody(
            postData: postData,
            hashtag: null,
            maxLines: 999999999999999,
            likesManager: likesManager,
          ),
          uid == "123"
              ? Container()
              : Container(
                  //action bar
                  key: GlobalKey(),
                  height: 30,
                  child: Row(children: <Widget>[
                    Expanded(
                      //like bar
                      child: StreamBuilder(
                          stream: rebuildLikesButton,
                          builder: (context, snapshot) {
                            print("Building Stream Builder");
                            if (snapshot.hasData) {
                              print(
                                  "New data in stream. Creating new Like Button");
                              currLikeButton = createLikesFutureBuilder(
                                  likesService, postData, uid);
                              return currLikeButton;
                            } else {
                              print("Using old LikeButton");
                              return currLikeButton;
                            }
                          }),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: CommentButton(
                        pid: postData.id,
                      ),
                    )),
                    Expanded(
                      child: ShareBar(
                        postId: postData.id,
                        postTitle: postData.title,
                      ),
                    ),
                  ]),
                ),
          Row(children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(10),
                child: Text(
                  howLongAgo(postData.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            postData.author != uid
                ? Container()
                : Container() // Decided against allowing deletion on view post controller for now as passing the reloading to feed is difficult
            /*FlatButton(
                    onPressed: () {
                      print('button pressed');
                      _showDeleteDialog(postData, context);
                    },
                    child: Text('Delete',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        )),
                  ),*/
          ])
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    LikesService likesService = LikesService(uid: "123");
    if (user != null) {
      likesService = LikesService(uid: user.uid);
    }

    print("View post controller");

    return Container(
        child: postData == null
            ? Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(""),
                  actions: <Widget>[
                    new IconButton(
                        icon: new Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ],
                  leading: new Container(),
                ),
                body: Container(
                    child: Text(
                        "Error retrieving post: either the post does not exist, or your internet is not connected")))
            : WillPopScope(
                onWillPop: () async => false,
                child: Scaffold(
                    appBar: kIsWeb == true
                        ? null
                        : AppBar(
                            centerTitle: true,
                            title: Text(postData.status.inCaps),
                            actions: <Widget>[
                              new IconButton(
                                  icon: new Icon(Icons.close),
                                  onPressed: () {
                                    print("Going back from ViewPost to Feed");
                                    Navigator.of(context).pop();
                                  })
                            ],
                            leading: new Container(),
                          ),
                    body: VisibilityDetector(
                      key: UniqueKey(),
                      onVisibilityChanged: (VisibilityInfo info) {
                        debugPrint(
                            "${info.visibleFraction} of my widget is visible");
                        if (info.visibleFraction > 0 &&
                            willNeedUpdate == true) {
                          reloadPost();
                        }
                      },
                      child: Column(children: [
                        kIsWeb == true ? WebMenu(-1) : Container(),
                        Expanded(
                          child: ListView(
                            children: <Widget>[
                              Container(
                                  color: Colors.white,
                                  child: Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      child: Column(
                                        children: <Widget>[
                                          user != null
                                              ? createPostUI(postData, user.uid,
                                                  context, likesService)
                                              : createPostUI(postData, '123',
                                                  context, likesService),
                                          PrimaryFundderButton(
                                              text: 'Donate',
                                              onPressed: () async {
                                                willNeedUpdate = true;
                                                //This is the old code for redirecting to a donation page within the app
                                                //apple and google don't allow this without taking a 30% cut

                                                /*Navigator.of(context).push(_openDonate());*/
                                                // Navigator.pushNamed(
                                                //     context,
                                                //     '/post/' +
                                                //         postData.id +
                                                //         '/donate');
                                                String uid;
                                                if (user != null) {
                                                  uid = user.uid;
                                                } else {
                                                  uid = '123';
                                                }
                                                var donatePage =
                                                    "https://donate.fundder.co/" +
                                                        uid +
                                                        '/' +
                                                        postData.id;

                                                // var url = "https://fundder.co/";
                                                if (await canLaunch(
                                                    donatePage)) {
                                                  await launch(
                                                    donatePage,
                                                    forceSafariVC: false,
                                                    forceWebView: false,
                                                  );
                                                } else {
                                                  throw 'Could not launch $donatePage';
                                                }
                                              }),
                                          user != null
                                              ? user.uid != postData.author ||
                                                      postData.status != 'fund'
                                                  ? Container()
                                                  : PrimaryFundderButton(
                                                      text:
                                                          'Complete Challenge',
                                                      onPressed: () {
                                                        willNeedUpdate = true;
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/post/' +
                                                                postData.id +
                                                                '/uploadProof');
                                                      })
                                              : Container(),
                                        ],
                                      )))
                            ],
                          ),
                        ),
                      ]),
                    ))));
  }

  void reloadPost() async {
    print('reloading');
    postData = await DatabaseService(uid: "123").getPostById(this.postData.id);
    if (mounted) {
      if (mounted)
        setState(() {
          willNeedUpdate = false;
        });
    }
  }

  FutureBuilder createLikesFutureBuilder(likesService, postData, uid) {
    bool initiallyHasLiked;
    int initialLikesNo;
    return FutureBuilder(
        future: likesService.hasUserLikedPost(postData.id),
        builder: (context, hasLiked) {
          Widget child1 = Container(
            width: 0,
          );
          if (hasLiked.connectionState == ConnectionState.done) {
            initiallyHasLiked = hasLiked.data;
            return FutureBuilder(
              future: likesService.noOfLikes(postData.id),
              builder: (context, noLikes) {
                Widget child;
                if (noLikes.connectionState == ConnectionState.done) {
                  initialLikesNo = noLikes.data;

                  child = NewLikeButton(
                    initiallyHasLiked,
                    initialLikesNo,
                    uid: uid,
                    postId: postData.id,
                  );
                } else {
                  child =
                      /*previousLikesNo != null && previousHasLiked != null
                        ? NewLikeButton(previousHasLiked, previousLikesNo,
                            uid: uid, postId: postData.id)
                        :*/
                      Container(
                    width: 0,
                  );
                }
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: child,
                );
              },
            );
          } else {
            child1 = Container(
              width: 0,
            );
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: child1,
          );
        });
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
}
