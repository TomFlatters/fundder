//!!!!!!!!!!!!!!This file is way way tooooo big
//really needs to be refactored

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_widgets/commentBar.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/post_widgets/shareBar.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/services/likes.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'models/post.dart';
import 'share_post_view.dart';
import 'helper_classes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'video_item.dart';
import 'services/likes.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FeedView extends StatefulWidget {
  @override
  _FeedViewState createState() => _FeedViewState();

  final VoidCallback onDeletePressed;
  final List<Post> postList;
  final String hashtag;
  FeedView(this.postList, this.onDeletePressed, this.hashtag, {Key key});
}

class _FeedViewState extends State<FeedView> {
  ScrollPhysics physics;
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'addMessage',
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    LikesModel likesModel;
    print("feed being built");
    final user = Provider.of<User>(context);
    final LikesService likesService = LikesService(uid: user.uid);
    if (widget.postList == null) {
      return Text("No data...");
    } else {
      return ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 10.0),
        itemCount: widget.postList.length,
        itemBuilder: (BuildContext context, int index) {
          //building an individual post
          Post postData = widget.postList[index];
          // print(postData)
          bool initiallyHasLiked;
          int initialLikesNo;
          return GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.only(left: 0, right: 0, top: 0),
                child: Column(children: <Widget>[
                  PostHeader(
                      postAuthorId: postData.author,
                      postAuthorUserName: postData.authorUsername,
                      targetCharity: postData.charity,
                      postStatus: postData.status),
                  PostBody(
                    postData: postData,
                    hashtag: widget.hashtag,
                  ),
                  Container(
                    //action bar
                    key: GlobalKey(),
                    height: 30,
                    child: Row(children: <Widget>[
                      FutureBuilder(
                          future: likesService.hasUserLikedPost(postData.id),
                          builder: (context, hasLiked) {
                            if (hasLiked.connectionState ==
                                ConnectionState.done) {
                              initiallyHasLiked = hasLiked.data;
                              return FutureBuilder(
                                future: likesService.noOfLikes(postData.id),
                                builder: (context, noLikes) {
                                  if (noLikes.connectionState ==
                                      ConnectionState.done) {
                                    initialLikesNo = noLikes.data;
                                    likesModel = LikesModel(
                                        initiallyHasLiked, initialLikesNo,
                                        uid: user.uid, postId: postData.id);
                                    return Expanded(
                                      //like bar
                                      child: ChangeNotifierProvider(
                                          create: (context) => likesModel,
                                          child: LikeBar()),
                                    );
                                  } else {
                                    return Expanded(
                                      child: Container(),
                                    );
                                  }
                                },
                              );
                            } else {
                              return Expanded(
                                child: Container(),
                              );
                            }
                          }),
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
                    postData.author != user.uid
                        ? Container()
                        : FlatButton(
                            onPressed: () {
                              print('button pressed');
                              _showDeleteDialog(postData);
                            },
                            child: Text('Delete',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                )),
                          ),
                  ])
                ]),
              ),
            ),
            onTap: () async {
              //
              //throw StateError('Uncaught error thrown by app.');
              // var pid = postData.id;
              // var noLikes = likesModel.noLikes;
              // var isLiked = likesModel.isLiked;
              // var uid = user.uid;
              // //passing state into ViewPost screen
              // LikesModel likeState = LikesModel(isLiked, noLikes,
              //     uid: uid, postId: pid);
              if (likesModel != null) {
                var newState = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewPost(postData)));
                likesModel.manuallySetState(
                    newState['noLikes'], newState['isLiked']);
              }
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 10,
          );
        },
      );
    }
  }

  Future<void> _showDeleteDialog(Post post) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Once you delete this post, all the money donated will be refunded unless you have uploaded proof of challenge completion. This cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                Firestore.instance
                    .collection('posts')
                    .document(post.id)
                    .delete()
                    .then((value) {
                  Navigator.of(context).pop();
                  widget.onDeletePressed();
                });
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
