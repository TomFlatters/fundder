import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsService {
  final String uid;
  final String postId;
  CommentsService({this.uid, this.postId});

  final CollectionReference postsCollection =
      Firestore.instance.collection('posts');

  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  Stream<List<DocumentSnapshot>> get comments {
    print('returning comments for  post: {$postId}');
    return postsCollection
        .document(postId)
        .collection('comments')
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((q) => q.documents);
  }

  //add a comment to a post postId
  void addAcomment(Map comment) {
    postsCollection.document(postId).collection('comments').add({
      'uid': uid,
      'username': comment['username'],
      'timestamp': comment['timestamp'],
      'text': comment['text']
    });
  }
}
