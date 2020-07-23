import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/likes.dart';

class LikeBar extends StatefulWidget {
  final String postId;
  LikeBar({this.postId});
  @override
  _LikeBarState createState() => _LikeBarState(postId: postId);
}

class _LikeBarState extends State<LikeBar> {
  final String postId;
  _LikeBarState({this.postId});

  FlatButton createHeart(bool hasLiked, LikesService likesService) {
    return FlatButton(
        child: Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(0.0),
            child: (hasLiked)
                ? Image.asset('assets/images/like_selected.png')
                : Image.asset('assets/images/like.png')),
        onPressed: () {
          setState(() {
            print("I'm pressing like!!!!!");
            if (hasLiked) {
              likesService.unlikePost(postId);
            } else {
              likesService.likePost(postId);
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final LikesService likesService = LikesService(uid: user.uid);

    return Row(
      children: <Widget>[
        FutureBuilder(
            future: likesService.hasUserLikedPost(postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return createHeart(snapshot.data, likesService);
              } else {
                return Container();
              }
            }),
        FutureBuilder(
            future: likesService.noOfLikes(postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(snapshot.data.toString()));
              } else {
                return Container();
              }
            })
      ],
    );
  }
}
