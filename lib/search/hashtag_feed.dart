import 'package:flutter/material.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
import 'package:fundder/feed_wrapper.dart';

class HashtagFeed extends StatelessWidget {
  final String hashtag;
  final String count;
  // int noLikes;
  // bool hasLiked;

  HashtagFeed(this.hashtag, this.count
      /*{this.noLikes, this.hasLiked}*/
      );

  @override
  Widget build(BuildContext context) {
    print('feed controller instantiated');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("#" + hashtag),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
        leading: new Container(),
      ),
      body: Column(children: [
        Text(count + ' posts'),
        SizedBox(
          height: 5,
        ),
        Expanded(child: FeedWrapper('hashtag', hashtag, 'hashtag')),
      ]),
    );
  }
}
