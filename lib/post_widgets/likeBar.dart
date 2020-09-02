import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/likes.dart';
import 'package:fundder/helper_classes.dart';

// class LikesModel extends ChangeNotifier {
//   //the 'state' of the likes on a 'postId' post in 'uid' user's feed is housed here
// //i.e the number of likes of this post as well as well as whether uid has liked postId
//   bool _isLiked;
//   int _noLikes;
//   final String postId;
//   final String uid;
//   final LikesService _likesService;

//   LikesModel(bool initialIsLiked, int initialNoLikes, {this.uid, this.postId})
//       : this._likesService = LikesService(uid: uid) {
//     _isLiked = initialIsLiked;
//     _noLikes = initialNoLikes;
//   }

//   int get noLikes => _noLikes;
//   bool get isLiked => _isLiked;

//   void likePressed() {
//     if (_isLiked) {
//       _likesService.unlikePost(postId);
//       _noLikes -= 1;
//       _isLiked = false;
//     } else {
//       _likesService.likePost(postId);
//       _noLikes += 1;
//       _isLiked = true;
//     }
//     notifyListeners();
//   }

//   void manuallySetState(int noLikes, bool isLiked) {
//     _noLikes = noLikes;
//     _isLiked = isLiked;
//     notifyListeners();
//   }
// }

// class LikeBar extends StatelessWidget {
//   //the widget will listen to a likesModel to interact with the state. It will be rebuilt everytime the state changes in LikesModel.
//   //must be placed in below a LikesModel in widget tree
//   @override
//   Widget build(BuildContext context) {
//     var likesModel = Provider.of<LikesModel>(context);
//     return FlatButton(
//         onPressed: () {
//           likesModel.likePressed();
//         },
//         child: Container(
//             height: 40,
//             child: Row(children: <Widget>[
//               Expanded(
//                   child: Row(children: [
//                 Container(
//                   width: 25,
//                   height: 25,
//                   padding: const EdgeInsets.all(0.0),
//                   child: (likesModel.isLiked)
//                       ? Image.asset('assets/images/like_selected.png',
//                           color: HexColor('ff6b6c'))
//                       : Image.asset('assets/images/like.png',
//                           color: Colors.grey[850]),
//                 ),
//                 Expanded(
//                     child: Container(
//                         margin: EdgeInsets.only(left: 10),
//                         child: Text(
//                           likesModel.noLikes != null
//                               ? likesModel.noLikes.toString()
//                               : "",
//                           style:
//                               TextStyle(fontSize: 16, color: Colors.grey[850]),
//                           textAlign: TextAlign.left,
//                         )))
//               ]))
//             ])));
//   }
// }

class NewLikeButton extends StatefulWidget {
  //LOOk UP WHERE STATE IS ACTUALLY KEPT IN THESE WIDGETS
  final bool initialIsLiked;
  final int initialNoLikes;
  final String postId;
  final String uid;
  final LikesService likesService;
  NewLikeButton(this.initialIsLiked, this.initialNoLikes,
      {@required this.uid, @required this.postId})
      : this.likesService = LikesService(uid: uid);

  @override
  _NewLikeButtonState createState() => _NewLikeButtonState();
}

class _NewLikeButtonState extends State<NewLikeButton>
    with TickerProviderStateMixin {
  bool isLiked;
  int noLikes;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 1).animate(_controller);
    _controller.forward();
    isLiked = widget.initialIsLiked;
    noLikes = widget.initialNoLikes;
  }

  void likePressed() {
    if (mounted)
      setState(() {
        if (isLiked) {
          widget.likesService.unlikePost(widget.postId);
          noLikes -= 1;
          isLiked = false;
        } else {
          widget.likesService.likePost(widget.postId);
          noLikes += 1;
          isLiked = true;
        }
        _controller.forward(from: 0.0);
      });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: likePressed,
        child: Container(
            height: 40,
            child: FadeTransition(
                opacity: _animation,
                child: Row(children: <Widget>[
                  Container(
                    width: 25,
                    height: 25,
                    padding: const EdgeInsets.all(0.0),
                    child: (isLiked)
                        ? Image.asset('assets/images/like_selected.png',
                            color: HexColor('ff6b6c'))
                        : Image.asset('assets/images/like.png',
                            color: Colors.grey[850]),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 10, top: 5),
                      child: Text(
                        noLikes != null ? noLikes.toString() : "",
                        style: TextStyle(fontSize: 16, color: Colors.grey[850]),
                        textAlign: TextAlign.left,
                      ),
                    ), /*Text(
                        noLikes != null ? noLikes.toString() : "",
                        style: TextStyle(fontSize: 16, color: Colors.grey[850]),
                        textAlign: TextAlign.left,
                      )*/
                  )
                ]))));
  }

  @override
  void dispose() {
    _controller.dispose(); // you need this
    super.dispose();
  }
}
