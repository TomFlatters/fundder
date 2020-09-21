import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyService {
  final String uid;
  PrivacyService(this.uid);

  final CollectionReference _userCollection =
      Firestore.instance.collection('users');

  /**Changes the 'isPrivate' field of the user to newVal  */
  Future<Void> changePrivacySetting(newVal) async {
    await _userCollection
        .document(uid)
        .setData({'isPrivate': newVal}, merge: true);
  }
}
