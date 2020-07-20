/*
We have three objectives with the <like> functionality:

1. We want to see how many likes a post has
2. We want to know who liked a post
3. We want to keep track of posts that've been liked by the user
*/
import 'package:cloud_firestore/cloud_firestore.dart';

class LikesService {
  //initiate the class with user id
  final String uid;
  LikesService({this.uid});
  final CollectionReference postsCollection =
      Firestore.instance.collection('posts');

  Future likePost(String postId) async {
    await postsCollection
        .document(postId)
        .collection('whoLiked')
        .add({uid: true});
    await postsCollection.document(postId).updateData({
      'likes': FieldValue.increment(1)
    }); //increment is apparently a great feature
  }
}
