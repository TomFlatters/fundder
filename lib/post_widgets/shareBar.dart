import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/share_post_view.dart';

class ShareBar extends StatelessWidget {
  void _showShare(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SharePost();
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
                  style: TextStyle(fontSize: 17, color: Colors.grey[850]),
                )))
      ]),
      onPressed: () {
        _showShare(context);
      },
    );
  }
}
