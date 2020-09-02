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

class PostBody extends StatelessWidget {
  final Post postData;
  final String hashtag;
  final int maxLines;
  PostBody({this.postData, this.hashtag, this.maxLines});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
                margin: EdgeInsets.only(bottom: 10.0),
              ),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(10),
            child: Text(postData.title,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20))),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
            child: RichText(
                maxLines: this.maxLines,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    children: _returnHashtags(postData.hashtags, context)))),
        Container(
          //alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
          child: LinearPercentIndicator(
            linearStrokeCap: LinearStrokeCap.roundAll,
            lineHeight: 5,
            percent: postData.percentRaised(),
            backgroundColor: HexColor('CCCCCC'),
            progressColor: HexColor('ff6b6c'),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 15, top: 0, left: 10, right: 10),
            child: Text(
              '£${postData.moneyRaised == null ? 0.00.toStringAsFixed(2) : postData.moneyRaised.toStringAsFixed(2)} raised of £${postData.targetAmount} target',
              style: TextStyle(fontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  List<TextSpan> _returnHashtags(List hashtags, BuildContext context) {
    List<TextSpan> hashtagText = [
      TextSpan(
          text: postData.subtitle + " ",
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Founders Grotesk',
              fontSize: 16))
    ];
    if (hashtags != null) {
      for (var i = 0; i < hashtags.length; i++) {
        hashtagText.add(TextSpan(
            text: "#" + hashtags[i].toString() + " ",
            style: TextStyle(
                color: Colors.blueGrey[700] /*HexColor('ff6b6c')*/,
                fontFamily: 'Founders Grotesk',
                fontSize: 16),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (hashtags[i].toString() != hashtag) {
                  Navigator.pushNamed(
                      context, '/hashtag/' + hashtags[i].toString());
                }
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
              imageUrl: (postData.imageUrl != null) ? postData.imageUrl : '',
              placeholder: (context, url) => Loading(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
    }
  }
}
