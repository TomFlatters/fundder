import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/user.dart';

class DatabaseService {

  // initiate the class with the user id
  final String uid;
  DatabaseService({ this.uid });

  // Get Firestore collection reference
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference postsCollection = Firestore.instance.collection('posts');

  // Update User
  Future updateUserData(String email, String username, String name) async {
    // create or update the document with this uid
    return await userCollection.document(uid).setData({
      'email': email,
      'username': username,
      'name': name,
    });
  }

  // Get users stream
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }

  // Get posts list stream is mapped to the Post object
  List<Post> _postsDataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      // print(doc.data['timestamp'].toString());
      return Post(
        author: doc.data['author'],
        title: doc.data['title'],
        charity: doc.data['charity'],
        amountRaised: doc.data['amountRaised'],
        targetAmount: doc.data['targetAmount'],
        likes: doc.data['likes'],
        comments: doc.data['comments'],
        subtitle: doc.data['subtitle'],
        timestamp: doc.data['timestamp'],
      );
    }).toList();
  }
  // Get list of posts
  Stream<List<Post>> get posts {
    return postsCollection.snapshots().map(_postsDataFromSnapshot);
  }

  /*User _userDataFromSnapshot(QuerySnapshot snapshot) {
    return User(
      uid: doc.data['uid'],
      username: ,
      email: ,
      bio: ,
      followers: ,
      following: ,
      gender: 
    );
  }*/
  

}