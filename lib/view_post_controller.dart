import 'package:flutter/material.dart';
import 'package:fundder/post_widgets/socialBar.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'post_widgets/postHeader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/post.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'global_widgets/buttons.dart';
import 'services/database.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:async';
import 'package:fundder/routes/FadeTransition.dart';
import 'messaging/chat_room.dart';

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

  Container createPostUI(Post postData, String uid, context) {
    StreamController<void> likesManager = StreamController<int>.broadcast();
    Stream rebuildLikesButton = likesManager.stream;

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
              postStatus: postData.status,
              charityLogo: postData.charityLogo),
          PostBody(
            postData: postData,
            hashtag: null,
            maxLines: 999999999999999,
            likesManager: likesManager,
          ),
          uid == "123"
              ? Container()
              : SocialBar(
                  key: UniqueKey(),
                  postData: postData,
                  rebuildLikesButton: rebuildLikesButton,
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
          ])
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("View post controller");
    final user = Provider.of<User>(context);
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
            : Scaffold(
                appBar: AppBar(
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
                    if (info.visibleFraction > 0 && willNeedUpdate == true) {
                      reloadPost();
                    }
                  },
                  child: Column(children: [
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Container(
                              color: Colors.white,
                              child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Column(
                                    children: <Widget>[
                                      user != null
                                          ? createPostUI(
                                              postData, user.uid, context)
                                          : createPostUI(
                                              postData, '123', context),
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
                                            if (await canLaunch(donatePage)) {
                                              await launch(
                                                donatePage,
                                                forceSafariVC: false,
                                                forceWebView: false,
                                              );
                                            } else {
                                              throw 'Could not launch $donatePage';
                                            }
                                          }),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      user != null
                                          ? user.uid != postData.author ||
                                                  postData.status != 'fund'
                                              ? user.uid != postData.author
                                                  ? EditFundderButton(
                                                      text:
                                                          'Message ${postData.authorUsername}',
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ChatRoom(
                                                                        postData
                                                                            .author,
                                                                        postData
                                                                            .authorUsername)));
                                                      })
                                                  : Container()
                                              : Column(children: [
                                                  PrimaryFundderButton(
                                                      text:
                                                          'Complete Challenge',
                                                      onPressed: () {
                                                        willNeedUpdate = true;
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/post/' +
                                                                postData.id +
                                                                '/uploadProof');
                                                      }),
                                                  /*SizedBox(
                                                    height: 20,
                                                  ),
                                                  SecondaryFundderButton(
                                                    onPressed: () {
                                                      willNeedUpdate = true;
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/post/' +
                                                              postData.id +
                                                              '/uploadProgress');
                                                    },
                                                    text: 'Upload Progress',
                                                  )*/
                                                ])
                                          : Container(),
                                    ],
                                  )))
                        ],
                      ),
                    ),
                  ]),
                )));
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
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
}
