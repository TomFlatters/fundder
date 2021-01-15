import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fundder/services/database.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:fundder/routes/FadeTransition.dart';
import 'package:fundder/profile_screens/user_loader.dart';
import 'challengeService.dart';
import 'package:share/share.dart';

class ChallengeDetail extends StatefulWidget {
  final String challengeId;
  ChallengeDetail({this.challengeId});

  _ChallengeDetailState createState() => _ChallengeDetailState();
}

class _ChallengeDetailState extends State<ChallengeDetail> {
  @override
  Widget build(BuildContext context) {
    bool hasAccepted = false;
    String username = '';
    String uid = '';
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    if (arguments != null) {
      username = arguments['username'].toString();
      uid = arguments['uid'].toString();
    }

    return FutureBuilder(
        future: DatabaseService().getChallengeById(widget.challengeId),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            print('Username: ' + username);
            List acceptedBy = snapshot.data['acceptedBy'];
            if (acceptedBy.contains(uid.toString())) {
              hasAccepted = true;
            }
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text("Do a Challenge"),
                actions: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(null),
                  )
                ],
                leading: new Container(),
              ),
              body: Column(children: [
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      snapshot.data['aspectRatio'] != null
                          ? Container(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width /
                                    snapshot.data['aspectRatio'],
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data['imageUrl'] != null
                                      ? snapshot.data['imageUrl']
                                      : "",
                                  placeholder: (context, url) => Loading(),
                                  errorWidget: (context, url, error) =>
                                      Container(
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
                          color: Colors.white,
                          child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    height: 30,
                                    child: Row(children: <Widget>[
                                      /*Expanded(
                                        child: Center(
                                            child: Text(
                                          "£${snapshot.data.moneyRaised.toStringAsFixed(2)} raised",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        )),
                                      ),*/
                                      Expanded(
                                        child: Center(
                                            child: Text(
                                          "${acceptedBy.length} participants",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        )),
                                      ),
                                      Expanded(
                                        child: Center(
                                            child: Text(
                                          "${howLongAgo(snapshot.data['timestamp'])}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        )),
                                      ),
                                    ]),
                                  ),
                                  Container(
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text(
                                          snapshot.data['title'],
                                          style: TextStyle(
                                              fontFamily: 'Founders Grotesk',
                                              //fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )),
                                        GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  '/charity/' +
                                                      snapshot.data['charity']);
                                            },
                                            child: Container(
                                                height: 20,
                                                //color: Colors.blue,
                                                margin: EdgeInsets.only(
                                                    right: 10.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: snapshot
                                                      .data['charityLogo'],
                                                  //color: Colors.red,
                                                )))
                                      ])),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: RichText(
                                          text: TextSpan(
                                        children: _returnHashtags(
                                            snapshot.data['hashtags'],
                                            context,
                                            snapshot.data['subtitle']),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ))),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Text(
                                        'A challenge for ${snapshot.data['charity']} by ${snapshot.data['authorUsername']}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                  ),
                                  PrimaryFundderButton(
                                      text: 'Share link',
                                      onPressed: () async {
                                        ChallengeService challengeService =
                                            ChallengeService();
                                        Uri shortUrl = await challengeService
                                            .createChallengeLink(
                                                widget.challengeId,
                                                snapshot.data['imageUrl']);
                                        Share.share(
                                            'You have been challenged!\n ' +
                                                shortUrl.toString(),
                                            subject: snapshot.data['title']);
                                      }),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  PrimaryFundderButton(
                                      text: hasAccepted
                                          ? 'Your Post'
                                          : 'Join Now',
                                      onPressed: () {
                                        if (hasAccepted) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserLoader(uid: uid)));
                                        } else {
                                          Navigator.pushNamed(
                                              context,
                                              '/direct_challenge/' +
                                                  widget.challengeId);
                                        }
                                      }),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SecondaryFundderButton(
                                      text: 'View Accepted',
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context,
                                            '/challengesFeed/' +
                                                widget.challengeId +
                                                '/' +
                                                snapshot.data['title'] +
                                                '/' +
                                                acceptedBy.length.toString());
                                      }),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              )))
                    ],
                  ),
                ),
              ]),
            );
          } else {
            return Loading();
          }
        });
  }

  List<TextSpan> _returnHashtags(
      List hashtags, BuildContext context, String templateText) {
    List<TextSpan> hashtagText = [
      TextSpan(
          text: templateText + " ",
          style: TextStyle(color: Colors.black, fontFamily: 'Founders Grotesk'))
    ];
    if (hashtags != null) {
      for (var i = 0; i < hashtags.length; i++) {
        hashtagText.add(TextSpan(
            text: "#" + hashtags[i].toString() + " ",
            style: TextStyle(
                color: Colors.blueGrey[700],
                fontFamily: 'Founders Grotesk' /*HexColor('ff6b6c')*/),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(
                    context, '/hashtag/' + hashtags[i].toString());
              }));
      }
    }
    return hashtagText;
  }
}
