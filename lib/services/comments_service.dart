import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsService {
  final String uid;
  CommentsService({this.uid});

  final CollectionReference postsCollection =
      Firestore.instance.collection('posts');

  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  //add a comment to a post postId
  void addAcomment(String postId, Map comment) {
    postsCollection.document(postId).collection('comments').add({
      'uid': uid,
      'username': comment['username'],
      'timestamp': comment['timestamp'],
      'text': comment['text']
    });
  }
}
