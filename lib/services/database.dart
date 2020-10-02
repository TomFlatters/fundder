import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
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
  final cloudFunc = CloudFunctions.instance;
  // .useFunctionsEmulator(origin: 'http://10.0.2.2:5001');

  DatabaseService({this.uid});

  // Get Firestore collection reference
  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference postsCollection =
      Firestore.instance.collection('postsV2');
  final CollectionReference templatesCollection =
      Firestore.instance.collection('templates');
  final CollectionReference charitiesCollection =
      Firestore.instance.collection('charities');

  // -------------
  // 1. User CRUD:
  // -------------

  // Create: Users are created upon registration.
  // TBC by refactor

  /** Read: user information by the id used to instantiate the DatabaseService*/
  Future<User> readUserData() async {
    DocumentSnapshot userData = await userCollection.document(uid).get();
    print("_readUserData invoked: \n" + userData.data.toString());
    User fetchedUser = userDataFromSnapshot(userData);
    return fetchedUser;
  }

  /** Update User */
  Future updateUserData(
      String email, String username, String name, String profilePic) async {
    // create or update the document with this uid
    return await userCollection.document(uid).updateData({
      'email': email,
      'username': username,
      'search_username': username != null ? username.toLowerCase() : null,
      'name': name,
      'profilePic': profilePic,
    });
  }

  /**  only call this on registration, since it sets profile pic and tutorials viewed as false */
  Future registerUserData(
      String email, String username, String name, String profilePic) async {
    // create or update the document with this uid
    return await userCollection.document(uid).setData({
      'email': email,
      'username': username,
      'search_username': username != null ? username.toLowerCase() : null,
      'name': name,
      'profilePic': profilePic,
      'seenTutorial': false,
      'dpSetterPrompted': false,
    }, merge: true);
  }

  Future addFacebookId(String facebookId) async {
    return await userCollection
        .document(uid)
        .setData({'facebookId': facebookId}, merge: true);
  }

  Future addFacebookToken(String facebookToken) async {
    return await userCollection
        .document(uid)
        .setData({'facebookToken': facebookToken}, merge: true);
  }

  Future addProfilePic(String location) async {
    return await userCollection
        .document(uid)
        .setData({'profilePic': location}, merge: true);
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

  Stream<DocumentSnapshot> userStream(String uid) {
    return Firestore.instance.collection('users').document(uid).snapshots();
  }

  /**Given a document return a User type object*/
  User userDataFromSnapshot(DocumentSnapshot doc) {
    //print("_userDataFromSnapshot invoked. This is the username: " +
    //   doc.data["username"]);

    //print("this is the field value for isPrivate!!!!! : " +
    //   doc.data['isPrivate']);
    return User(
        isPrivate: (doc.data['isPrivate'] != null)
            ? (true == doc.data['isPrivate'])
            : false, //isPrivate,
        uid: doc.documentID,
        username: doc.data['username'],
        email: doc.data['email'],
        bio: doc.data['bio'],
        followers: doc.data['noFollowers'],
        following: doc.data['noFollowing'],
        gender: doc.data['gender'],
        name: doc.data['name'],
        profilePic: doc.data['profilePic'],
        seenTutorial: doc.data['seenTutorial'],
        dpSetterPrompted: doc.data['dpSetterPrompted'],
        verified: doc.data['verified'],
        profileTutorialSeen: doc.data['profileTutorialSeen'],
        fundTutorialSeen: doc.data['fundTutorialSeen'],
        doTutorialSeen: doc.data['doTutorialSeen'],
        doneTutorialSeen: doc.data['doneTutorialSeen'],
        likes: doc.data['likes'],
        facebookId: doc.data['facebookId'],
        facebookToken: doc.data['facebookToken'],
        amountDonated: doc.data['amountDonated'] != null
            ? doc.data['amountDonated'].toDouble()
            : 0.0);
  }

  // -------------
  // 2. Posts CRUD:
  // -------------

  /**  Given a document return a Post type object */
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
      aspectRatio: (doc.data['aspectRatio'] != null)
          ? doc.data['aspectRatio'].toDouble()
          : doc.data['aspectRatio'],
      hashtags: doc.data['hashtags'],
      completionComment: doc.data['completionComment'],
      charityLogo: doc.data['charityLogo'] != null
          ? doc.data['charityLogo']
          : 'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/charity_logos%2FImage%201.png?alt=media&token=5c937368-4081-4ac1-bb13-36be561e4f1a',
    );
  }

  /**  Get posts list from a query */
  List<Post> _postsDataFromSnapshot(QuerySnapshot snapshot) {
    print('mapping the posts to Post model');
    return snapshot.documents.map((DocumentSnapshot doc) {
      return _makePost(doc);
    }).toList();
  }

/**Make a post object from a JSON */
  Post aJSONtoPost(postJSON) {
    print("aJSONtoPost being run");
    var isPrivate =
        (postJSON["isPrivate"] == null) ? false : postJSON['isPrivate'];
    print("private setting of this post is: " + isPrivate.toString());
    print(
        "in aJSONtoPost and the values of the seconds in the timestamp is ${postJSON['timestamp']['_seconds']}");
    var timeStampSecs = postJSON['timestamp']['_seconds'];
    var timeStampNanoSecs = postJSON['timestamp']['_nanoseconds'];
    //print("printing noLikes:" + doc["noLikes"]);
    return Post(
      //need to make a fromJSON initialisor in Post
      isPrivate: isPrivate,
      noLikes: (postJSON["noLikes"] == null)
          ? (postJSON['likes'].length)
          : (postJSON["noLikes"]),
      peopleThatLikedThis: Set(),
      author: postJSON['author'],
      authorUsername: postJSON['authorUsername'],
      title: postJSON['title'],
      charity: postJSON['charity'],
      amountRaised: postJSON['amountRaised'],
      moneyRaised: (postJSON['moneyRaised'] != null)
          ? postJSON['moneyRaised'].toDouble()
          : postJSON['moneyRaised'],
      targetAmount: postJSON['targetAmount'],
      likes: postJSON['likes'],
      noComments: postJSON['noComments'],
      subtitle: postJSON['subtitle'],
      timestamp: Timestamp(timeStampSecs, timeStampNanoSecs),
      imageUrl: postJSON['imageUrl'],
      id: postJSON['postId'],
      status: postJSON['status'],
      aspectRatio: (postJSON['aspectRatio'] != null)
          ? postJSON['aspectRatio'].toDouble()
          : postJSON['aspectRatio'],
      hashtags: postJSON['hashtags'],
      completionComment: postJSON['completionComment'],
      charityLogo: postJSON['charityLogo'] != null
          ? postJSON['charityLogo']
          : 'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/charity_logos%2FImage%201.png?alt=media&token=5c937368-4081-4ac1-bb13-36be561e4f1a',
    );
  }

/**Make a list of Posts objects from a list of JSONS */
  List<Post> jsonsToPosts(List<Object> postJSONS) {
    print('mapping the posts to Post model');
    return postJSONS.map((postJSON) {
      return aJSONtoPost(postJSON);
    }).toList();
  }

/**Get a list of up to three new posts of appropriate status (fund/done) */
  Future<List<Post>> refreshPosts(
      String status, int limit, Timestamp startTimestamp) async {
    print("in refresh posts");
    HttpsCallable cloudRefreshPosts =
        cloudFunc.getHttpsCallable(functionName: 'onRefreshPost');
    HttpsCallableResult res = await cloudRefreshPosts.call(<String, dynamic>{
      'status': status,
      'limit': limit,
      "timeStamp":
          startTimestamp.toString(), //needs to be converted server side
    });
    print("printing timestamp in toString format ${startTimestamp.toString()}");
    print("printing result of refresh feed: " +
        res.data["listOfJsonDocs"].toString());

    var postList = jsonsToPosts(res.data["listOfJsonDocs"]);

    return postList;
  }

  /**Get up to 'limit' number of post documents ordered by timestamp
   * starting at 'startTimestamp' containing hashtag 'hashtag' 
   */
  Future<List<Post>> refreshHashtag(
      String hashtag, int limit, Timestamp startTimestamp) async {
    print("running refresh hashtag");
    print('limit: ' + limit.toString());

    HttpsCallable cloudRefreshHashtag =
        cloudFunc.getHttpsCallable(functionName: 'onRefreshHashtag');
    HttpsCallableResult res = await cloudRefreshHashtag.call(<String, dynamic>{
      'hashtag': hashtag,
      'limit': limit,
      "timeStamp": startTimestamp.toString(), //this is converted server side
    });

    print("printing result of refresh hashtag: " +
        res.data["listOfJsonDocs"].toString());

    var postList = jsonsToPosts(res.data["listOfJsonDocs"]);

    return postList;
  }

  /**Get posts by author id */
  Future<List<Post>> authorPosts(String id) async {
    //TODO: only if you follow the author
    print('gettig posts by author: ' + id);

    HttpsCallable getAuthorPosts =
        cloudFunc.getHttpsCallable(functionName: 'getAuthorPosts');
    HttpsCallableResult res = await getAuthorPosts.call(<String, dynamic>{
      'id': id,
    });
    print("printing result of author posts: " +
        res.data["listOfJsonDocs"].toString());

    var postList = jsonsToPosts(res.data["listOfJsonDocs"]);

    return postList;

    /*
    return postsCollection
        .where("author", isEqualTo: id)
        .orderBy("timestamp", descending: true)
        .getDocuments()
        .then((snapshot) {
      return _postsDataFromSnapshot(snapshot);
    });
    */
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

  /** Upload post and return the document id*/
  Future uploadPost(Post post) async {
    return await postsCollection
        .add({
          "isPrivate": post.isPrivate,
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
        aspectRatio: (doc.data['aspectRatio'] != null)
            ? doc.data['aspectRatio'].toDouble()
            : doc.data['aspectRatio'],
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
