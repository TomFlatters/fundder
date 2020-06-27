import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  // Given a document return a Post type
  Post _makePost(DocumentSnapshot doc){
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
        imageUrl: doc.data['imageUrl'],
      );
  }

  // Get posts list stream is mapped to the Post object
  List<Post> _postsDataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((DocumentSnapshot doc){
      // print(doc.data['timestamp'].toString());
      return _makePost(doc);
    }).toList();
  }

  // Get list of posts
  Stream<List<Post>> get posts {
    return postsCollection.orderBy("timestamp", descending: true).limit(10).snapshots().map(_postsDataFromSnapshot);
  }

  // Upload post and return the document id
  Future uploadPost(Post post) async {
    return await postsCollection.add({
        "author": post.author,
        "title": post.title,
        "charity": post.charity,
        "amountRaised": post.amountRaised,
        "targetAmount": post.targetAmount,
        "likes": post.likes,
        "comments": post.comments,
        "subtitle": post.subtitle,
        "timestamp": post.timestamp,
        "imageUrl": post.imageUrl,
    })
    .then((DocumentReference docRef) => {
      docRef.documentID.toString()
    })
    .catchError((error) => {
      print(error)
    });
  }

  Future getPostById(String documentId) async {
    String formattedId = documentId.substring(1, documentId.length-1);
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
  final StorageReference storageRef = FirebaseStorage().ref().child("images/");

  // Image upload
  Future uploadImage(PickedFile file, String location) async {
    var imageRef = storageRef.child(location);
    var uploadTask = imageRef.putFile(File(file.path));
    // await the task uploaded
    var storageTaskSnapshot = await uploadTask.onComplete;
    // then return the downloadURL
    if(storageTaskSnapshot != null){
      var downloadUrl = await imageRef.getDownloadURL();
      return downloadUrl.toString();
    }
  }

}