import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/template.dart';
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
  final CollectionReference templatesCollection =
      Firestore.instance.collection('templates');
  final CollectionReference charitiesCollection =
      Firestore.instance.collection('charities');

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
    return await userCollection.document(uid).setData({
      'email': email,
      'username': username,
      'search_username': username.toLowerCase(),
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
    var isPrivate =
        (doc.data['isPrivate'] != null) ? doc.data['isPrivate'] : false;
    print("this is the field value for isPrivate!!!!! : " +
        doc.data['isPrivate']);
    return User(
        isPrivate: isPrivate,
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

  // -------------
  // 2. Posts CRUD:
  // -------------

  // Given a document return a Post type object
  Post _makePost(DocumentSnapshot doc) {
    print("_makePost being run");
    var isPrivate =
        (doc.data["isPrivate"] == null) ? false : doc.data['isPrivate'];
    print("private setting of this post is: " + isPrivate.toString());

    //print("printing noLikes:" + doc["noLikes"]);
    return Post(
      isPrivate: isPrivate,
      noLikes: (doc.data["noLikes"] == null)
          ? (doc['likes'].length)
          : (doc["noLikes"]),
      peopleThatLikedThis: Set(),
      author: doc.data['author'],
      authorUsername: doc.data['authorUsername'],
      title: doc.data['title'],
      charity: doc.data['charity'],
      amountRaised: doc.data['amountRaised'],
      moneyRaised: (doc.data['moneyRaised'] != null)
          ? doc.data['moneyRaised'].toDouble()
          : doc.data['moneyRaised'],
      targetAmount: doc.data['targetAmount'],
      likes: doc.data['likes'],
      noComments: doc.data['noComments'],
      subtitle: doc.data['subtitle'],
      timestamp: doc.data['timestamp'],
      imageUrl: doc.data['imageUrl'],
      id: doc.documentID,
      status: doc.data['status'],
      aspectRatio: doc.data['aspectRatio'],
      hashtags: doc.data['hashtags'],
      completionComment: doc.data['completionComment'],
      charityLogo: doc.data['charityLogo'] != null
          ? doc.data['charityLogo']
          : 'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/charity_logos%2FImage%201.png?alt=media&token=5c937368-4081-4ac1-bb13-36be561e4f1a',
    );
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

  Future<List<Post>> refreshHashtag(
      String hashtag, int limit, Timestamp startTimestamp) {
    print('limit: ' + limit.toString());
    return postsCollection
        .orderBy("timestamp", descending: true)
        .startAfter([startTimestamp])
        .limit(limit)
        .where('hashtags', arrayContains: hashtag)
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

  Future<List<Post>> likedPosts(String id, List likesList) {
    print('getting liked posts by author: ' + id);
    return postsCollection
        .where(FieldPath.documentId, whereIn: likesList)
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
          "moneyRaised": post.moneyRaised,
          "targetAmount": post.targetAmount,
          "noLikes": post.noLikes,
          "noComments": post.noComments,
          "subtitle": post.subtitle,
          "timestamp": post.timestamp,
          "imageUrl": post.imageUrl,
          'status': post.status,
          'templateTag': post.templateTag,
          'aspectRatio': post.aspectRatio,
          "hashtags": post.hashtags,
          'charityLogo': post.charityLogo
        })
        .then((DocumentReference docRef) => {docRef.documentID.toString()})
        .catchError((error) => {print(error)});
  }

  // // Get a post from Firestore given a known id: if the post id is bracketted these are automatically removed
  // Future getPostById(String documentId) async {
  //   String formattedId = (documentId.substring(0, 1) == "{" &&
  //           documentId.substring(documentId.length - 1) == "}")
  //       ? documentId.substring(1, documentId.length - 1)
  //       : documentId;
  //   print('Formatted data: ' + formattedId);
  // Get a post from Firestore given a known id
  Future<Post> getPostById(String documentId) async {
    String formattedId = documentId.substring(0,
        documentId.length); // I think this needs to be changed for older posts
    DocumentReference docRef = postsCollection.document(formattedId);
    return await docRef.get().then((DocumentSnapshot doc) {
      print(doc);
      if (doc.exists) {
        print("Document data: " + doc.data.toString());
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

  // ------------------
  // 3. Templates CRUD:
  // ------------------

  // Given a document return a Template object
  Template _makeTemplate(DocumentSnapshot doc) {
    return Template(
        author: doc.data['author'],
        authorUsername: doc.data['authorUsername'],
        title: doc.data['title'],
        charity: doc.data['charity'],
        moneyRaised: doc.data['moneyRaised'].toDouble(),
        targetAmount: doc.data['targetAmount'],
        likes: doc.data['likes'],
        comments: doc.data['comments'],
        subtitle: doc.data['subtitle'],
        timestamp: doc.data['timestamp'],
        imageUrl: doc.data['imageUrl'],
        id: doc.documentID,
        whoDoes: doc.data['whoDoes'],
        acceptedBy: doc.data['acceptedBy'],
        completedBy: doc.data['completedBy'],
        active: doc.data['active'],
        aspectRatio: doc.data['aspectRatio'],
        hashtags: doc.data['hashtags'],
        charityLogo: doc.data['charityLogo'] != null
            ? doc.data['charityLogo']
            : 'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/charity_logos%2FImage%201.png?alt=media&token=5c937368-4081-4ac1-bb13-36be561e4f1a');
  }

  // Get a post from Firestore given a known id: if the id is bracketed these are automatically removed
  Future getTemplateById(String documentId) async {
    String formattedId = (documentId.substring(0, 1) == "{" &&
            documentId.substring(documentId.length - 1) == "}")
        ? documentId.substring(1, documentId.length - 1)
        : documentId;
    print(formattedId);
    DocumentReference docRef = templatesCollection.document(formattedId);
    return await docRef.get().then((DocumentSnapshot doc) {
      print(doc);
      if (doc.exists) {
        print("Document data:" + doc.data.toString());
        return _makeTemplate(doc);
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

  Future uploadTemplate(Template t) async {
    return await templatesCollection
        .add({
          "author": t.author,
          "authorUsername": t.authorUsername,
          "title": t.title,
          "charity": t.charity,
          "moneyRaised": t.moneyRaised,
          "targetAmount": t.targetAmount,
          "likes": t.likes,
          "comments": t.comments,
          "subtitle": t.subtitle,
          "timestamp": t.timestamp,
          "imageUrl": t.imageUrl,
          "whoDoes": t.whoDoes,
          "acceptedBy": t.acceptedBy,
          "completedBy": t.completedBy,
          "active": t.active,
          "aspectRatio": t.aspectRatio,
          "hashtags": t.hashtags,
          "charityLogo": t.charityLogo
        })
        .then((DocumentReference docRef) => {docRef.documentID.toString()})
        .catchError((error) => {print(error)});
  }

  // Get templates list is mapped to the Template object
  List<Template> _templatesDataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((DocumentSnapshot doc) {
      return _makeTemplate(doc);
    }).toList();
  }

  Future<List<Template>> getTemplates() {
    return templatesCollection
        .limit(10)
        .orderBy("timestamp", descending: true)
        .getDocuments()
        .then((snapshot) => _templatesDataFromSnapshot(snapshot));
  }

  // Batch query to add a post from a template when a user accepts challenge
  Future uploadPostFromTemplate(Template template, User user,
      Map<String, dynamic> postData, String fetchedUsername) async {
    var batch = Firestore.instance.batch();
    // Update accepted by
    batch.updateData(templatesCollection.document(template.id), {
      'acceptedBy': [...template.acceptedBy, fetchedUsername]
    });
    // Add new post with given data
    DocumentReference postId = postsCollection.document();
    batch.setData(postId, postData);
    return await batch.commit().then((_) => postId);
  }

  // For the DO feed
  Future<List<Template>> refreshTemplates(int limit, Timestamp startTimestamp) {
    print('limit: ' + limit.toString());
    return templatesCollection
        .orderBy("timestamp", descending: true)
        .startAfter([startTimestamp])
        .limit(limit)
        .getDocuments()
        .then((snapshot) {
          print(_templatesDataFromSnapshot(snapshot));
          return _templatesDataFromSnapshot(snapshot);
        });
  }

  // -----------------------------------
  // 4. Firebase Storage (image upload):
  // -----------------------------------

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
      "moneyRaised": post.moneyRaised,
      "targetAmount": post.targetAmount,
      "likes": post.likes,
      "noComments": post.noComments,
      "subtitle": post.subtitle,
      "timestamp": post.timestamp,
      "imageUrl": post.imageUrl,
      "status": post.status,
      'aspectRatio': post.aspectRatio,
      'hashtags': post.hashtags
    });
  }

  Future updatePostStatusImageTimestampRatioComment(
      String postId,
      String downloadUrl,
      String status,
      Timestamp timestamp,
      double aspectRatio,
      String completionComment) async {
    // create or update the document with this uid
    return await postsCollection.document(postId).updateData({
      "imageUrl": downloadUrl,
      "status": status,
      "timestamp": timestamp,
      "aspectRatio": aspectRatio,
      "completionComment": completionComment
    });
  }

  Future<List<DocumentSnapshot>> usersContainingString(String queryText) {
    return userCollection
        .orderBy('search_username', descending: false)
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

  Future<List<DocumentSnapshot>> hashtagsContainingString(String queryText) {
    if (queryText != "") {
      return Firestore.instance
          .collection('hashtags')
          .orderBy(FieldPath.documentId, descending: false)
          .startAt([queryText])
          .endAt([queryText + '\uf8ff'])
          //.where(FieldPath.documentId, isGreaterThanOrEqualTo: queryText)
          .limit(20)
          .getDocuments()
          .then((snapshot) {
            return snapshot.documents.map((DocumentSnapshot doc) {
              return doc;
            }).toList();
          });
    } else {
      return Firestore.instance
          .collection('hashtags')
          //.where(FieldPath.documentId, isGreaterThanOrEqualTo: queryText)
          .limit(20)
          .getDocuments()
          .then((snapshot) {
        return snapshot.documents.map((DocumentSnapshot doc) {
          return doc;
        }).toList();
      });
    }
  }

// -----------------------------------
// 5. Charities:
// -----------------------------------

// Use this function to get the data to display about the charity when their
// logo is clicked.
  Future<Charity> readCharitiesData(name) async {
    DocumentSnapshot charityData =
        await charitiesCollection.document(name).get();
    Charity fetchedCharity = _charityDataFromDoc(charityData);
    return fetchedCharity;
  }

  Charity _charityDataFromDoc(DocumentSnapshot doc) {
    return Charity(
        name: doc.data['name'],
        id: doc.documentID,
        bio: doc.data['bio'],
        location: doc.data['location'],
        image: doc.data['image']);
  }

  Future<List<Charity>> getCharityNameList() async {
    QuerySnapshot charitiesSnapshot = await charitiesCollection.getDocuments();
    return charitiesSnapshot.documents.map((DocumentSnapshot doc) {
      return _charityDataFromDoc(doc);
    }).toList();
  }
}
