import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseService {
  // initiate the class with the user id
  final String uid;
  DatabaseService({this.uid});

  // Get Firestore collection reference
  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference postsCollection =
      Firestore.instance.collection('posts');

  // -------------
  // 1. User CRUD:
  // -------------

  // Create: Users are created upon registration.
  // TBC by refactor

  // Read: user information by the id used to instantiate the DatabaseService
  Future<User> readUserData() async {
    DocumentSnapshot userData = await userCollection.document(uid).get();
    User fetchedUser = _userDataFromSnapshot(userData);
    return fetchedUser;
  }

  // Update User
  Future updateUserData(
      String email, String username, String name, String profilePic) async {
    // create or update the document with this uid
    return await userCollection.document(uid).updateData({
      'email': email,
      'username': username,
      'name': name,
      'profilePic': profilePic,
    });
  }

  // only call this on registration, since it sets profile pic and tutorials viewed as false
  Future registerUserData(
      String email, String username, String name, String profilePic) async {
    // create or update the document with this uid
    return await userCollection.document(uid).updateData({
      'email': email,
      'username': username,
      'name': name,
      'profilePic': profilePic,
      'seenTutorial': false,
      'dpSetterPrompted': false,
    });
  }

  Future addFCMToken(String token) async {
    // create or update the document with this uid
    return await userCollection.document(uid).updateData({
      "fcm": FieldValue.arrayUnion([token])
    });
  }

  Future removeFCMToken(String token) async {
    if (token != null) {
      // create or update the document with this uid
      return await userCollection.document(uid).updateData({
        "fcm": FieldValue.arrayRemove([token])
      });
    } else {
      return null;
    }
  }

  // Get users stream
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }

  // Given a document return a User type object
  User _userDataFromSnapshot(DocumentSnapshot doc) {
    return User(
        uid: doc.data['uid'],
        name: doc.data['name'],
        username: doc.data['username'],
        email: doc.data['email'],
        bio: doc.data['bio'],
        followers: doc.data['followers'],
        following: doc.data['following'],
        gender: doc.data['gender'],
        profilePic: doc.data['profilePic']);
  }

  // Given a document return a Post type object
  Post _makePost(DocumentSnapshot doc) {
    print("_makePost being run");

    //print("printing noLikes:" + doc["noLikes"]);
    return Post(
        noLikes: (doc.data["noLikes"] == null)
            ? (doc['likes'].length)
            : (doc["noLikes"]),
        peopleThatLikedThis: Set(),
        author: doc.data['author'],
        authorUsername: doc.data['authorUsername'],
        title: doc.data['title'],
        charity: doc.data['charity'],
        amountRaised: doc.data['amountRaised'],
        targetAmount: doc.data['targetAmount'],
        likes: doc.data['likes'],
        noComments: doc.data['noComments'],
        subtitle: doc.data['subtitle'],
        timestamp: doc.data['timestamp'],
        imageUrl: doc.data['imageUrl'],
        id: doc.documentID,
        status: doc.data['status'],
        aspectRatio: doc.data['aspectRatio']);
  }

  // Get posts list stream is mapped to the Post object
  List<Post> _postsDataFromSnapshot(QuerySnapshot snapshot) {
    print('mapping the posts to Post model');
    return snapshot.documents.map((DocumentSnapshot doc) {
      return _makePost(doc);
    }).toList();
  }

  // Get list of posts ordered by time
  Stream<List<Post>> get fundPosts {
    return postsCollection
        .orderBy("timestamp", descending: true)
        .limit(10)
        .where('status', isEqualTo: 'fund')
        .snapshots()
        .map(_postsDataFromSnapshot);
  }

  Stream<List<Post>> get donePosts {
    print('returning done posts');
    return postsCollection
        .orderBy("timestamp", descending: true)
        .limit(10)
        .where('status', isEqualTo: 'done')
        .snapshots()
        .map(_postsDataFromSnapshot);
  }

  Future<List<Post>> refreshPosts(
      String status, int limit, Timestamp startTimestamp) {
    print('limit: ' + limit.toString());
    return postsCollection
        .orderBy("timestamp", descending: true)
        .startAfter([startTimestamp])
        .limit(limit)
        .where('status', isEqualTo: status)
        .getDocuments()
        .then((snapshot) {
          print(_postsDataFromSnapshot(snapshot));
          return _postsDataFromSnapshot(snapshot);
        });
  }

  Future<List<Post>> authorPosts(String id) {
    print('gettig posts by author: ' + id);
    return postsCollection
        .where("author", isEqualTo: id)
        .orderBy("timestamp", descending: true)
        .getDocuments()
        .then((snapshot) {
      return _postsDataFromSnapshot(snapshot);
    });
  }

  // Get list of posts for given author
  Stream<List<Post>> postsByUser(id) {
    return postsCollection
        .where("author", isEqualTo: id)
        .orderBy("timestamp", descending: true)
        .limit(10)
        .snapshots()
        .map(_postsDataFromSnapshot);
  }

/*
  Stream<List<Post>> postsLikedByUser(id) {
    return postsCollection
        .where("likes", arrayContains: id)
        .orderBy("timestamp", descending: true)
        .limit(10)
        .snapshots()
        .map(_postsDataFromSnapshot);
  }
*/

  // Upload post and return the document id
  Future uploadPost(Post post) async {
    return await postsCollection
        .add({
          "author": post.author,
          "authorUsername": post.authorUsername,
          "title": post.title,
          "charity": post.charity,
          "amountRaised": post.amountRaised,
          "targetAmount": post.targetAmount,
          "noLikes": post.noLikes,
          "noComments": post.noComments,
          "subtitle": post.subtitle,
          "timestamp": post.timestamp,
          "imageUrl": post.imageUrl,
          'status': post.status,
          'aspectRatio': post.aspectRatio
        })
        .then((DocumentReference docRef) => {docRef.documentID.toString()})
        .catchError((error) => {print(error)});
  }

  // Get a post from Firestore given a known id
  Future getPostById(String documentId) async {
    String formattedId = documentId.substring(0,
        documentId.length); // I think this needs to be changed for older posts
    DocumentReference docRef = postsCollection.document(formattedId);
    return await docRef.get().then((DocumentSnapshot doc) {
      print(doc);
      if (doc.exists) {
        print("Document data:" + doc.data.toString());
        return _makePost(doc);
      } else {
        // doc.data() will be undefined in this case
        print("Error - the post you are looking for doesn't exist.");
        return null;
      }
    }).catchError((error) {
      print("Error getting document: " + error);
      return null;
    });
  }

  // Storage ref:
  // Images are stored as <root>/images/<uid>/<milliseconds-from-epoch>
  // BE AWARE: this convention will cause a naming conflict if one user uploads multiple images at the exact same time

  // Image upload
  Future uploadImage(File file, String location) async {
    final StorageReference storageRef =
        FirebaseStorage().ref().child("images/");
    var imageRef = storageRef.child(location);
    var uploadTask = imageRef.putFile(File(file.path));
    // await the task uploaded
    var storageTaskSnapshot = await uploadTask.onComplete;
    // then return the downloadURL
    if (storageTaskSnapshot != null) {
      var downloadUrl = await imageRef.getDownloadURL();
      return downloadUrl.toString();
    }
  }

  Future uploadVideo(File file, String location) async {
    final StorageReference storageRef =
        FirebaseStorage().ref().child("videos/");
    StorageReference imageRef = storageRef.child(location);
    StorageUploadTask uploadTask = imageRef.putFile(
        File(file.path), StorageMetadata(contentType: 'video/mp4'));
    // await the task uploaded
    var storageTaskSnapshot = await uploadTask.onComplete;
    // then return the downloadURL
    if (storageTaskSnapshot != null) {
      var downloadUrl = await imageRef.getDownloadURL();
      return downloadUrl.toString();
    }
  }

  Future updatePostData(Post post) async {
    // create or update the document with this uid
    return await postsCollection.document(post.id).setData({
      "noLikes": post.noLikes,
      "author": post.author,
      "authorUsername": post.authorUsername,
      "title": post.title,
      "charity": post.charity,
      "amountRaised": post.amountRaised,
      "targetAmount": post.targetAmount,
      "likes": post.likes,
      "noComments": post.noComments,
      "subtitle": post.subtitle,
      "timestamp": post.timestamp,
      "imageUrl": post.imageUrl,
      "status": post.status,
      'aspecRatio': post.aspectRatio
    });
  }

  Future updatePostStatusImageTimestampRatio(String postId, String downloadUrl,
      String status, Timestamp timestamp, double aspectRatio) async {
    // create or update the document with this uid
    return await postsCollection.document(postId).updateData({
      "imageUrl": downloadUrl,
      "status": status,
      "timestamp": timestamp,
      "aspectRatio": aspectRatio
    });
  }

  Future<List<DocumentSnapshot>> usersContainingString(String queryText) {
    return userCollection
        .orderBy('username', descending: false)
        .startAt([queryText])
        .endAt([queryText + '\uf8ff'])
        .limit(20)
        .getDocuments()
        .then((snapshot) {
          return snapshot.documents.map((DocumentSnapshot doc) {
            return doc;
          }).toList();
        });
  }

  Future<List<DocumentSnapshot>> postsContainingString(String queryText) {
    return postsCollection
        .orderBy('subtitle', descending: false)
        .startAt([queryText])
        .endAt([queryText + '\uf8ff'])
        .limit(20)
        .getDocuments()
        .then((snapshot) {
          return snapshot.documents.map((DocumentSnapshot doc) {
            return doc;
          }).toList();
        });
  }
}
