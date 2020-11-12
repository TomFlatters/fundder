import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class ChallengeService {
  //need a mechanism to upload to the challenges collection....
  final CollectionReference challengesCollection =
      Firestore.instance.collection('challenges');
  final CollectionReference postsCollection =
      Firestore.instance.collection('postsV2');

  /**Get the the document of a specfic challenge from the challenge collection
   */

  Future<DocumentSnapshot> getChallenge(String challengeId) =>
      challengesCollection.document(challengeId).get();

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

/**Create a link for a challenge in the Challenges collection. This link, when
 * clicked will lead to a view in the app where the user can accept the challenge 
 * or reject the challenge.
 */
  Future<String> createChallengeLink(String challengeDocId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://fundderchallenge.page.link',
      link: Uri.parse('https://app.fundder.co/challenge/${challengeDocId}'),
      androidParameters: AndroidParameters(
        packageName: 'com.fundder',
        minimumVersion: 0,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.fundder',
        minimumVersion: '1.0.0',
        appStoreId: '1529120882',
      ),
    );

    final Uri dynamicUrl = await parameters.buildUrl();

    return dynamicUrl.toString();
  }

/**When the user accepts a challenge, make a post out of it and upload to the 
 * db and add the user to list of people who accepted the challenge.
 * 
 */

  Future acceptChallenge(
      DocumentSnapshot challengeDoc, String uid, String username) async {
    DocumentReference newPostRef = await postsCollection.add({
      "challengeId": challengeDoc.documentID,
      "isPrivate": false,
      "author": uid,
      "authorUsername": username,
      "title": challengeDoc["title"],
      "charity": challengeDoc["charity"],
      "amountRaised": "0.00",
      "moneyRaised": 0.00,
      "targetAmount": challengeDoc["targetAmount"],
      "noLikes": 0,
      "noComments": 0,
      "subtitle": challengeDoc["subtitle"],
      "timestamp": Timestamp.now(),
      "imageUrl": challengeDoc["imageUrl"],
      "status": "fund",
      "aspectRatio": challengeDoc["aspectRatio"],
      "hashtags": challengeDoc["hashtags"],
      "charityLogo": challengeDoc["charityLogo"],
    });

    //add this user the the list of people who've accepted the challenge
    challengesCollection.document(challengeDoc.documentID).updateData({
      "acceptedBy": FieldValue.arrayUnion([uid])
    });

    return newPostRef;
  }
}
