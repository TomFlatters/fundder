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
          return Container(
            height: 350,
            child: Scaffold(
              appBar: null,
              body: SharePost(
                postId: this.postId,
                postTitle: this.postTitle,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: 45,
        height: 45,
        child: Image.asset('assets/images/share.png'),
      ),
      /*Expanded(
            child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  'Share',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, color: Colors.grey[850]),
                )))*/
      onTap: () {
        _showShare(context);
      },
    );
  }
}
