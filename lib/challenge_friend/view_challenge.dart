import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/challenge_friend/challengeService.dart';
import 'package:fundder/shared/loading.dart';

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
              ? Container(
                  child: Text(challengeDoc.data.toString()),
                )
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
}
