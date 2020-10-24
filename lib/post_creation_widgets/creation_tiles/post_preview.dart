import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/charity.dart';
import 'package:provider/provider.dart';

class PostPreview extends StatelessWidget {
  final Charity charity;
  final String authorUid;
  final String authorUsername;
  final Widget imageView;
  final String title;
  final String subtitle;
  final int selected;
  final String targetAmount;
  final List<String> hashtags;
  PostPreview(
      {this.charity,
      this.authorUid,
      this.authorUsername,
      this.imageView,
      this.title,
      this.subtitle,
      this.selected,
      this.targetAmount,
      this.hashtags});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return ListView(children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Text(
                  selected == 0
                      ? 'This is what your post would look like:'
                      : 'This is what your challenge, once somebody accepts it, would look like:',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              PostHeader(
                  postAuthorId: authorUid,
                  postAuthorUserName: authorUsername,
                  targetCharity: charity.id,
                  charityLogo: charity.image),
              Container(
                child: SizedBox(child: imageView),
                margin: EdgeInsets.only(bottom: 10.0),
              ),
              PostBody(
                likesManager: null,
                maxLines: 99999999,
                postData: Post(
                    isPrivate: user.isPrivate,
                    title: title,
                    subtitle: subtitle,
                    hashtags: hashtags,
                    moneyRaised: 0,
                    targetAmount: selected != 1 ? targetAmount : '-1'),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}
