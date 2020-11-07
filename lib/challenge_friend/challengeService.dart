import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChallengeService {
  //need a mechanism to upload to the challenges collection....
  final CollectionReference challengesCollection =
      Firestore.instance.collection('challenges');

  /**Upload a challenge on to the database and return the docid of that 
   * challenge in the database.
   */

  Future<String> uploadChallenge(
      {@required String title,
      @required String subtitle,
      @required String author,
      @required String authorUsername,
      @required String charity,
      @required Timestamp timestamp,
      @required String targetAmount,
      @required String imageUrl,
      @required double aspectRatio,
      @required List hashtags,
      @required String charityLogo}) async {
    DocumentReference newChallengeDoc = await challengesCollection.add({
      "author": author,
      "authorUsername": authorUsername,
      "title": title,
      "charity": charity,
      "targetAmount": targetAmount,
      "subtitle": subtitle,
      "timestamp": timestamp,
      "imageUrl": imageUrl,
      "aspectRatio": aspectRatio,
      "hashtags": hashtags,
      "charityLogo": charityLogo,
      "acceptedBy": [],
    });

    return newChallengeDoc.documentID;
  }
}
