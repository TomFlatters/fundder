import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/likes.dart';

class LikesModel extends ChangeNotifier {
  //the 'state' of the likes on a 'postId' post in 'uid' user's feed is housed here
//i.e the number of likes of this post as well as well as whether uid has liked postId
  bool _isLiked;
  int _noLikes;
  final String postId;
  final String uid;
  final LikesService _likesService;

  LikesModel(bool initialIsLiked, int initialNoLikes, {this.uid, this.postId})
      : this._likesService = LikesService(uid: uid) {
    _isLiked = initialIsLiked;
    _noLikes = initialNoLikes;
  }

  int get noLikes => _noLikes;
  bool get isLiked => _isLiked;

  void likePressed() {
    if (_isLiked) {
      _likesService.unlikePost(postId);
      _noLikes -= 1;
      _isLiked = false;
    } else {
      _likesService.likePost(postId);
      _noLikes += 1;
      _isLiked = true;
    }
    notifyListeners();
  }

  void manuallySetState(int noLikes, bool isLiked) {
    _noLikes = noLikes;
    _isLiked = isLiked;
    notifyListeners();
  }
}

class LikeBar extends StatelessWidget {
  //the widget will listen to a likesModel to interact with the state. It will be rebuilt everytime the state changes in LikesModel.
  //must be placed in below a LikesModel in widget tree
  @override
  Widget build(BuildContext context) {
    var likesModel = Provider.of<LikesModel>(context);
    return Container(
        height: 30,
        child: Row(children: <Widget>[
          Expanded(
              child: FlatButton(
                  onPressed: () {
                    likesModel.likePressed();
                  },
                  child: Row(children: [
                    Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(0.0),
                      child: (likesModel.isLiked)
                          ? Image.asset('assets/images/like_selected.png')
                          : Image.asset('assets/images/like.png'),
                    ),
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              likesModel.noLikes.toString(),
                              textAlign: TextAlign.left,
                            )))
                  ])))
        ]));
  }
}
