import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentButton extends StatelessWidget {
  final String pid;
  CommentButton({this.pid});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: 43,
        height: 43,
        child: Image.asset(
          'assets/images/comment.png',
          color: Colors.grey[850],
        ),
      ),
      onTap: () {
        if (pid != null) {
          Navigator.pushNamed(context, '/post/' + pid + '/comments');
        }
      },
    );
  }
}
