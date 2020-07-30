import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentButton extends StatelessWidget {
  final String pid;
  CommentButton({this.pid});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Container(
        width: 20,
        height: 20,
        padding: const EdgeInsets.all(0.0),
        child: Image.asset('assets/images/comment.png'),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/post/' + widget.postData + '/comments');
      },
    );
  }
}
