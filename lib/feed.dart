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
import 'package:fundder/services/likes.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:fundder/view_post_controller.dart';
import 'package:provider/provider.dart';
import 'models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/likes.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'routes/FadeTransition.dart';
import 'post_widgets/socialBar.dart';
import 'package:fundder/global_widgets/dialogs.dart';

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
                        : FlatButton(
                            onPressed: () {
                              print('button pressed');
                              DialogManager().showDeleteDialog(
                                  postData, context, widget.onDeletePressed);
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
              print("a post clicked");
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewPost(postData)));
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
