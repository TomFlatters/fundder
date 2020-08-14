import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentButton extends StatelessWidget {
  final String pid;
  CommentButton({this.pid});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Container(
        width: 23,
        height: 23,
        padding: const EdgeInsets.all(0.0),
        child: Image.asset(
          'assets/images/comment.png',
          color: Colors.grey[850],
        ),
      ),
      onPressed: () {
        if (pid != null) {
          Navigator.pushNamed(context, '/post/' + pid + '/comments');
        }
      },
    );
  }
}
