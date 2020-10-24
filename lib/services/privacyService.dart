import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyService {
  final String uid;
  PrivacyService(this.uid);

  final CollectionReference _userCollection =
      Firestore.instance.collection('users');

  /**Changes the 'isPrivate' field of the user to newVal  */

  Future<Void> changePrivacySetting(newVal) async {
    print("changing privacy to: " + newVal.toString());
    await _userCollection
        .document(uid)
        .setData({'isPrivate': newVal}, merge: true);
  }

  /**Get the privacy status of the user */

  Future<bool> isPrivate() async {
    var userDoc = await _userCollection.document(uid).get();
    return (userDoc.data['isPrivate'] == true);
  }
}

class PostPrivacyToggle {
  final String postId;
  final CollectionReference _postsCollection =
      Firestore.instance.collection('postsV2');
  PostPrivacyToggle(this.postId);
  /**make this post private and available to all followers*/
  Future makePrivate() async {
    await _postsCollection
        .document(postId)
        .setData({'isPrivate': true}, merge: true);
    return;
  }

  /**Makes the post private and available only to specific followers */
  Future makeAvailableToSpecificPeople(List uids) async {
    await _postsCollection.document(postId).setData(
        {'isPrivate': true, 'selectedPrivateViewers': uids},
        merge: true);
    return;
  }

/**Makes a private post public.*/
  Future makePostPublic() async {
    //make the post public and remove selected followers
    await _postsCollection.document(postId).setData(
        {'isPrivate': false, 'selectedPrivateViewers': FieldValue.delete()},
        merge: true);
    return;
  }

/**
 * Checks the private status of this post and returns the selected private
 * viewers if they exist.
*/
  Future<Map> isPrivate() async {
    Map res = {};
    var postDoc = await _postsCollection.document(postId).get();
    res["isPrivate"] = postDoc.data["isPrivate"] == true;
    res["selectedViewers"] = postDoc.data['selectedPrivateViewers'];
    return res;
  }
}
