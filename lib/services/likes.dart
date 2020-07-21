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
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  //add user to the liked subcollection of the posts document 'postId'
  Future likePost(String postId) async {
    await postsCollection
        .document(postId)
        .collection('whoLiked')
        .add({uid: true});
    await postsCollection
        .document(postId)
        .updateData({'noLikes': FieldValue.increment(1)});
    await userCollection
        .document(uid)
        .collection('I_Liked')
        .add({postId: true});
  }

  Future unlikePost(String postId) async {
    //you can only unlike what you've liked, hence there's a document indicating this post is liked
    //TODO: make the code safer: what if somehow the user hasn't liked the post.
    //Then we'd be wrongly decrementing the like counter.
    CollectionReference myLikes =
        userCollection.document(uid).collection('I_Liked');
    var docs = await myLikes.where(postId, isEqualTo: true).getDocuments();
    var doc = docs.documents[0];
    var docid = doc.documentID;
    await myLikes.document(docid).updateData({postId: false});
    await postsCollection
        .document(postId)
        .updateData({'noLikes': FieldValue.increment(-1)});
  }

  //checks whether current user has liked a given post
  Future<bool> hasUserLikedPost(String postId) async {
    CollectionReference myLikes =
        userCollection.document(uid).collection('I_Liked');
    if (myLikes != null) {
      var result = await myLikes.where(postId, isEqualTo: true).getDocuments();
      print("documents retrieved from subcollection myLikes...");
      if (result.documents.length == 0) {
        print("no query found!!!!");
        return false;
      } else {
        result.documents.forEach((res) {
          print(res.data);
        });
      }
      return true;
    } else {
      print("The user has not liked anything");
      return false;
    }
  }
}
