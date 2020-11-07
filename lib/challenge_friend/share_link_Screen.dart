import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/challenge_friend/challengeService.dart';
import 'package:fundder/shared/loading.dart';

class ShareScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String author;
  final String authorUsername;
  final String charity;
  final Timestamp timestamp;
  final String targetAmount;
  final String imageUrl;
  final double aspectRatio;
  final List hashtags;
  final String charityLogo;

  ShareScreen(
      {@required this.title,
      @required this.subtitle,
      @required this.author,
      @required this.authorUsername,
      @required this.charity,
      @required this.timestamp,
      @required this.targetAmount,
      @required this.imageUrl,
      @required this.aspectRatio,
      @required this.hashtags,
      @required this.charityLogo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getChallengeDocId(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            String challengeDocId = snapshot.data;
            return _mainBody(challengeDocId: challengeDocId);
          } else {
            return Loading();
          }
        });
  }

  Widget _mainBody({@required String challengeDocId = 'nirvana'}) {
    return ListView(
      children: [
        Container(
            color: Colors.grey[200],
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(challengeDocId),
                    )
                  ],
                )))
      ],
    );
  }

  Future<String> getChallengeDocId() {
    ChallengeService challengeService = ChallengeService();
    return challengeService.uploadChallenge(
        title: title,
        subtitle: subtitle,
        author: author,
        authorUsername: authorUsername,
        charity: charity,
        timestamp: timestamp,
        targetAmount: targetAmount,
        imageUrl: imageUrl,
        aspectRatio: aspectRatio,
        hashtags: hashtags,
        charityLogo: charityLogo);
  }
}
