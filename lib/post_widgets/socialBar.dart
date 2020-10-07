import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import 'social_widgets/likeButton.dart';

import '../models/user.dart';
import '../services/likes.dart';
import 'social_widgets/commentBar.dart';
import 'social_widgets/shareBar.dart';
import 'dart:async';

class SocialBar extends StatefulWidget {
  //LOOk UP WHERE STATE IS ACTUALLY KEPT IN THESE WIDGETS
  final Post postData;
  Stream rebuildLikesButton;
  SocialBar({Key key, this.postData, this.rebuildLikesButton})
      : super(key: key);

  @override
  _SocialBarState createState() => _SocialBarState();
}

class _SocialBarState extends State<SocialBar> with TickerProviderStateMixin {
  StreamController<int> likesCountController =
      StreamController<int>.broadcast();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    LikesService likesService = LikesService(uid: "123");
    if (user != null) {
      likesService = LikesService(uid: user.uid);
    }
    var currLikeButton =
        createLikesFutureBuilder(likesService, widget.postData, "123");
    if (user != null) {
      currLikeButton =
          createLikesFutureBuilder(likesService, widget.postData, user.uid);
    }
    return Container(
        //action bar
        key: GlobalKey(),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            StreamBuilder(
                stream: widget.rebuildLikesButton,
                builder: (context, snapshot) {
                  print("Building Stream Builder");
                  if (snapshot.hasData) {
                    print("New data in stream. Creating new Like Button");
                    currLikeButton = createLikesFutureBuilder(
                        likesService, widget.postData, user.uid);
                    return currLikeButton;
                  } else {
                    print("Using old LikeButton");
                    return currLikeButton;
                  }
                }),
            CommentButton(
              pid: widget.postData.id,
            ),
            ShareBar(
              post: widget.postData,
            ),
          ]),
          Container(
            child: likesCountNumber(),
          )
        ]));
  }

  FutureBuilder createLikesFutureBuilder(likesService, postData, uid) {
    bool initiallyHasLiked;
    int initialLikesNo;
    return FutureBuilder(
        future: likesService.hasUserLikedPost(postData.id),
        builder: (context, hasLiked) {
          Widget child1 = Container(
            width: 45,
            height: 45,
          );
          if (hasLiked.connectionState == ConnectionState.done) {
            initiallyHasLiked = hasLiked.data;
            return FutureBuilder(
              future: likesService.noOfLikes(postData.id),
              builder: (context, noLikes) {
                Widget child;
                if (noLikes.connectionState == ConnectionState.done) {
                  initialLikesNo = noLikes.data;
                  likesCountController.add(initialLikesNo);
                  child = NewLikeButton(
                    initiallyHasLiked,
                    initialLikesNo,
                    uid: uid,
                    postId: postData.id,
                    likesNumberStreamController: likesCountController,
                  );
                } else {
                  child =
                      /*previousLikesNo != null && previousHasLiked != null
                        ? NewLikeButton(previousHasLiked, previousLikesNo,
                            uid: uid, postId: postData.id)
                        :*/
                      Container(
                    width: 45,
                    height: 45,
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
              width: 45,
              height: 45,
            );
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: child1,
          );
        });
  }

  StreamBuilder likesCountNumber() {
    return StreamBuilder(
        stream: likesCountController.stream,
        builder: (context, snapshot) {
          print('${snapshot.data}');
          return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                    context, '/post/' + widget.postData.id + '/likers');
              },
              child: Container(
                color: Colors.white,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  snapshot.data == null ? " " : '${snapshot.data} likes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),
              ));
        });
  }
}
