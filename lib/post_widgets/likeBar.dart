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
      _isLiked = true;
    }
    notifyListeners();
  }
}

class LikeBar extends StatelessWidget {
  //the widget will listen use likesModel to interact with the state. It will be rebuilt everytime the state changes.

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

// class LikeBar extends StatefulWidget {
//   final String postId;
//   LikeBar({
//     this.postId,
//   });
//   @override
//   _LikeBarState createState() => _LikeBarState(postId: postId);
// }

// class _LikeBarState extends State<LikeBar> {
//   final String postId;
//   _LikeBarState({this.postId});

//   FlatButton createHeart(bool hasLiked, LikesService likesService) {
//     return FlatButton(
//         padding: EdgeInsets.only(left: 10.0),
//         child: (hasLiked)
//             ? Image.asset('assets/images/like_selected.png')
//             : Image.asset('assets/images/like.png'),
//         onPressed: () {
//           setState(() {
//             print("I'm pressing like!!!!!");
//             if (hasLiked) {
//               likesService.unlikePost(postId);
//             } else {
//               likesService.likePost(postId);
//             }
//           });
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User>(context);
//     final LikesService likesService = LikesService(uid: user.uid);

//     return Row(
//       children: <Widget>[
//         Container(
//           height: 20,
//           width: 30,
//           child: FutureBuilder(
//               future: likesService.hasUserLikedPost(postId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return createHeart(snapshot.data, likesService);
//                 } else {
//                   return Container();
//                 }
//               }),
//         ),
//         Expanded(
//             child: FutureBuilder(
//                 future: likesService.noOfLikes(postId),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return Container(
//                         margin: EdgeInsets.only(left: 10),
//                         child: Text(
//                           snapshot.data.toString(),
//                           textAlign: TextAlign.left,
//                         ));
//                   } else {
//                     return Container();
//                   }
//                 }))
//       ],
//     );
//   }
// }
