/*
We have three objectives with the <like> functionality:

1. We want to see how many likes a post has
2. We want to know who liked a post
3. We want to keep track of posts that've been liked by the user

A good article for some basic but important know-how of cloud firestore.

https://petercoding.com/firebase/2020/04/04/using-cloud-firestore-in-flutter/


*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikesService {
  //initiate the class with user id
  final String uid;
  LikesService({this.uid});

  final CollectionReference postsCollection =
      Firestore.instance.collection('posts');
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  //add user to the liked subcollection of the posts document 'postId'
  void likePost(String postId) {
    postsCollection
        .document(postId)
        .collection('whoLiked')
        .document(uid)
        .setData({uid: true});
    postsCollection
        .document(postId)
        .updateData({'noLikes': FieldValue.increment(1)});
    userCollection.document(uid).updateData({
      'likes': FieldValue.arrayUnion([postId])
    });
  }

  void unlikePost(String postId) {
    //you can only unlike what you've liked, hence there's a document indicating this post is liked
    //TODO: Make the code safer: what if somehow the user hasn't liked the post.
    //Then we'd be wrongly decrementing the like counter.
    //TO DO: set my uid to false in whoLiked subcollection of posts

    //removing the like from the post
    postsCollection
        .document(postId)
        .collection('whoLiked')
        .document(uid)
        .setData({uid: false}, merge: true);
    postsCollection
        .document(postId)
        .updateData({'noLikes': FieldValue.increment(-1)});

    //removing the like from the user
    userCollection.document(uid).updateData({
      'likes': FieldValue.arrayRemove([postId])
    });
  }

  //checks whether current user has liked a given post
  Future<bool> hasUserLikedPost(String postId) async {
    DocumentSnapshot userprofile = await userCollection.document(uid).get();
    if (userprofile.data['likes'] == null) {
      return false;
    } else {
      return userprofile.data['likes'].contains(postId);
    }
  }

  Future<int> noOfLikes(String postId) async {
    var postDoc = await postsCollection.document(postId).get();
    return postDoc.data['noLikes'];
  }
}
