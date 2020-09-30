//!!!!!!!!!!!!!!This file is way way tooooo big
//really needs to be refactored
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_widgets/social_widgets/commentBar.dart';
import 'package:fundder/post_widgets/social_widgets/likeButton.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/post_widgets/social_widgets/shareBar.dart';
import 'package:fundder/privacyIcon.dart';
import 'package:fundder/services/likes.dart';
import 'package:fundder/services/privacyService.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:provider/provider.dart';
import 'helper_classes.dart';
import 'models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/likes.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'routes/FadeTransition.dart';
import 'post_widgets/socialBar.dart';

class FeedView extends StatefulWidget {
  @override
  _FeedViewState createState() => _FeedViewState();

  final VoidCallback onDeletePressed;
  final List<Post> postList;
  final String hashtag;
  FeedView(this.postList, this.onDeletePressed, this.hashtag, {Key key});
}

class _FeedViewState extends State<FeedView> {
  bool previousHasLiked;
  int previousLikesNo;

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

          //arbitrarily chosen int
          StreamController<void> likesManager =
              StreamController<int>.broadcast();
          Stream rebuildLikesButton = likesManager.stream;

          return GestureDetector(
            child: Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(10.0),
                  )),
              width: MediaQuery.of(context).size.width,
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
                    hashtag: widget.hashtag,
                    maxLines: 2,
                    likesManager: likesManager,
                  ),
                  SocialBar(
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
                    postData.author != user.uid
                        ? Container()
                        : Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    {_postOptions(context, user.uid, postData)},
                              )
                            ],
                          ),
                  ])
                ]),
              ),
            ),
            onTap: () async {
              print("a post clicked");
              await Navigator.push(
                  context, FadeRoute(page: ViewPost(postData)));
              likesManager.add(1);
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

  _postOptions(context, uid, postData) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 235,
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: ListView(
                children: [
                  SelectedFollowersOnlyPrivacyToggle(postData.id),
                  _createPrivacyIcon(postData.id),
                  ListTile(
                    leading: Icon(Icons.delete_forever),
                    title: Text('Delete'),
                    subtitle: Text(
                        "If this Fundder has not been completed, money raised will be refunded."),
                    onTap: () async {
                      print('elipses button pressed');
                      await _showDeleteDialog(postData);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
              ),
            ),
          );
        });
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
              child: Text('Delete', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Firestore.instance
                    .collection('postsV2')
                    .document(post.id)
                    .delete()
                    .then((value) {
                  Navigator.of(context).pop();
                  widget.onDeletePressed();
                });
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            previousHasLiked = initiallyHasLiked;
            return FutureBuilder(
              future: likesService.noOfLikes(postData.id),
              builder: (context, noLikes) {
                Widget child;
                if (noLikes.connectionState == ConnectionState.done) {
                  initialLikesNo = noLikes.data;
                  previousLikesNo = initialLikesNo;

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

_createPrivacyIcon(postId) {
  var postPrivacyToggle = PostPrivacyToggle(postId);
  return FutureBuilder(
    future: postPrivacyToggle.isPrivate(),
    builder: (context, isPrivate) {
      if (isPrivate.hasData) {
        var map = isPrivate.data;

        return PrivacyIcon(
            description: "Make this post viewable only to your followers",
            isPrivate: map['isPrivate'],
            onPrivacySettingChanged: (bool newVal) async {
              if (newVal) {
                await postPrivacyToggle.makePrivate();
              } else {
                await postPrivacyToggle.makePostPublic();
              }
            });
      } else {
        return ListTile(
          title: Text('Private Mode'),
          subtitle: Text("Make this post viewable only to your followers"),
          leading: Icon(Icons.lock_outline),
        );
      }
    },
  );
}
