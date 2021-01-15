import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fundder/challenge_friend/challengeService.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';

class ViewChallenge extends StatelessWidget {
  final String challengeId;
  ViewChallenge({@required this.challengeId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Challenge"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () {
                print("Going back from ViewPost to Feed");
                Navigator.of(context).pop();
              })
        ],
        leading: new Container(),
      ),
      body: _challengeBody(this.challengeId),
    );
  }

  Widget _challengeBody(String challengeId) {
    ChallengeService challengeService = ChallengeService();
    return FutureBuilder(
      future: challengeService.getChallenge(challengeId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot challengeDoc = snapshot.data;
          return (challengeDoc.exists)
              ? _renderUIfromDoc(challengeDoc, context)
              : Container(
                  child: Center(
                      child: Text(
                          "This challenge has been removed from our servers.")),
                );
        } else {
          return Loading();
        }
      },
    );
  }

  Widget _renderUIfromDoc(DocumentSnapshot challengeDoc, context) {
    Map challengeInfo = challengeDoc.data;
    User user = Provider.of<User>(context);
    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
            postAuthorId: challengeInfo['author'],
            postAuthorUserName: challengeInfo['authorUsername'],
            targetCharity: challengeInfo["charity"],
            charityLogo: challengeInfo["charityLogo"]),
        challengeInfo["aspectRatio"] != null
            ? Container(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width /
                      challengeInfo["aspectRatio"],
                  child: CachedNetworkImage(
                    imageUrl: challengeInfo["imageUrl"] != null
                        ? challengeInfo["imageUrl"]
                        : "",
                    placeholder: (context, url) => Loading(),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                    ),
                  ),
                ),
                margin: EdgeInsets.symmetric(vertical: 0.0),
              )
            : Container(
                height: 0,
              ),
        Container(
            //title
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(10),
            child: Text(challengeInfo["title"],
                style: TextStyle(
                  fontWeight: FontWeight.bold, /*fontSize: 18*/
                ))),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
            child: RichText(
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    children: _returnHashtags(challengeInfo["hashtags"],
                        context, user, challengeInfo["subtitle"])))),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 10, top: 0, left: 10, right: 10),
            child: Text(
              challengeInfo["targetAmount"] != '-1'
                  ? '£${challengeInfo["targetAmount"]} target'
                  : '£0.00 user-selected target',
              style: TextStyle(fontWeight: FontWeight.w500),
            )),
        /*Container(
          child: Text(challengeInfo.toString()),
        )*/
        SizedBox(
          height: 10,
        ),
        PrimaryFundderButton(
          onPressed: () async {
            Navigator.of(context).pop();
            ChallengeService challengeService = ChallengeService();
            var newPostRef = await challengeService.acceptChallenge(
                challengeDoc, user.uid, user.username);
            SnackBar snackBar = newPostRef != null
                ? SnackBar(
                    duration: const Duration(seconds: 3),
                    content: Text('Challenge Accepted'))
                : SnackBar(
                    duration: const Duration(seconds: 3),
                    content: Text('oops...something went wrong'));

            Scaffold.of(context).showSnackBar(snackBar);
          },
          text: "Accept",
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  List<TextSpan> _returnHashtags(
      List hashtags, BuildContext context, User user, subtitle) {
    List<TextSpan> hashtagText = [
      TextSpan(
          text: subtitle + " ",
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
                if (user != null) {
                  _openFeed(context, hashtags[i]);
                }
              }));
      }
    }
    return hashtagText;
  }

  void _openFeed(BuildContext context, String hashtag) async {
    await Navigator.pushNamed(context, '/hashtag/' + hashtag.toString());
    //this.likesManager.add(1);
  }
}
