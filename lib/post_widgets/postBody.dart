//will house the post title, desciption and media if there's any media, along
// with how much money has been raised so far

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/video_item.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fundder/search/hashtag_feed.dart';

class PostBody extends StatelessWidget {
  Post postData;
  PostBody({this.postData});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(10),
            child: Text(postData.title,
                style: TextStyle(fontWeight: FontWeight.bold))),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
            child: RichText(
                text: TextSpan(
                    children: _returnHashtags(postData.hashtags, context)))),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(
              '£${postData.moneyRaised} raised of £${postData.targetAmount} target',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        Container(
          //alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(top: 5, bottom: 15, left: 0, right: 0),
          child: LinearPercentIndicator(
            linearStrokeCap: LinearStrokeCap.butt,
            lineHeight: 3,
            percent: postData.percentRaised(),
            backgroundColor: HexColor('CCCCCC'),
            progressColor: HexColor('ff6b6c'),
          ),
        ),
        (postData.imageUrl == null)
            ? Container()
            : Container(
                child: postData.aspectRatio == null
                    ? SizedBox(child: _previewImageVideo(postData))
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width /
                            postData.aspectRatio,
                        child: _previewImageVideo(postData)),
                margin: EdgeInsets.symmetric(vertical: 10.0),
              ),
      ],
    );
  }

  List<TextSpan> _returnHashtags(List hashtags, BuildContext context) {
    List<TextSpan> hashtagText = [
      TextSpan(
          text: postData.subtitle + " ", style: TextStyle(color: Colors.black))
    ];
    if (hashtags != null) {
      for (var i = 0; i < hashtags.length; i++) {
        hashtagText.add(TextSpan(
            text: "#" + hashtags[i].toString() + " ",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: HexColor('ff6b6c')),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(
                    context, '/hashtag/' + hashtags[i].toString() + '/');
              }));
      }
    }
    return hashtagText;
  }

  Widget _previewImageVideo(Post postData) {
    if (postData.imageUrl.contains('video')) {
      print('initialising video');
      return VideoItem(key: UniqueKey(), url: postData.imageUrl);
    } else {
      return kIsWeb == true
          ? Image.network(postData.imageUrl)
          : CachedNetworkImage(
              imageUrl: (postData.imageUrl != null)
                  ? postData.imageUrl
                  : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
              placeholder: (context, url) => Loading(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
    }
  }
}
