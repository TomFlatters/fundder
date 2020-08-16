import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/share_post_view.dart';

class ShareBar extends StatelessWidget {
  final String postId;
  final String postTitle;

  ShareBar({@required this.postId, @required this.postTitle});

  void _showShare(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SharePost(
            postId: this.postId,
            postTitle: this.postTitle,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(children: [
        Container(
          width: 25,
          height: 25,
          padding: const EdgeInsets.all(0.0),
          child: Image.asset('assets/images/share.png'),
        ),
        Expanded(
            child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  'Share',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, color: Colors.grey[850]),
                )))
      ]),
      onPressed: () {
        _showShare(context);
      },
    );
  }
}
