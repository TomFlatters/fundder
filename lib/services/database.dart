import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  // initiate the class with the user id
  final String uid;
  DatabaseService({ this.uid });

  // Firestore collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');

  // change user by referencing document
  Future updateUserData(String email, String username, String name) async {
    // create or update the document with this uid
    return await userCollection.document(uid).setData({
      'email': email,
      'username': username,
      'name': name,
    });
  }

  // get users stream
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }

}