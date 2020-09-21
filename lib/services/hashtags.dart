/*
We have three objectives with the <hashtag> functionality:

1. We want to see the hashtags a post has
2. We want to know the posts in the hashtag
3. We want to keep track of the number of posts in hashtag

A good article for some basic but important know-how of cloud firestore.

Point 1 is handled when the post is created and we can find posts by quering the contains parameter of hashtags array in post
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HashtagsService {
  //initiate the class with user id
  final String uid;
  HashtagsService({this.uid});

  final CollectionReference postsCollection =
      Firestore.instance.collection('postsV2');
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  //add user to the liked subcollection of the posts document 'postId'
  void addHashtag(String postId, List<String> hashtags) {
    var batch = Firestore.instance.batch();
    for (var i = 0; i < hashtags.length; i++) {
      batch.setData(
          Firestore.instance.collection('hashtags').document(hashtags[i]),
          {'count': FieldValue.increment(1)},
          merge: true);
      batch.setData(
          Firestore.instance
              .collection('hashtags')
              .document(hashtags[i])
              .collection('posts')
              .document(postId),
          {postId: true},
          merge: true);
    }
    batch.commit();
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
