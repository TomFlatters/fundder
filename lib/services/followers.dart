import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class FollowersService {
  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final String uid;
  FollowersService({@required this.uid});

  void userFollowedSomeone(String newlyFollowedId) {
    //register this new followee on followed's doc in database
    userCollection
        .document(newlyFollowedId)
        .collection('myFollowers')
        .document(uid)
        .setData({'following': true, 'uid': uid}, merge: true);
    //add the followed on the followees' doc in the database
    userCollection
        .document(uid)
        .collection('following')
        .document(newlyFollowedId)
        .setData({'following': true, 'uid': newlyFollowedId}, merge: true);
  }

  void userUNfollowedSomeone(String recentlyUnfollowedId) {
    //remove the followee i.e. ourself from the followed's doc in database
    userCollection
        .document(recentlyUnfollowedId)
        .collection('myFollowers')
        .document(uid)
        .delete();
    //.setData({'following': false, 'uid': uid}, merge: true);
    //remove this receently unfollowed scumbag from our followers list
    userCollection
        .document(uid)
        .collection('following')
        .document(recentlyUnfollowedId)
        .delete();
    //.setData({'following': false, 'uid': recentlyUnfollowedId},
    //   merge: true);
  }

  Future<bool> doesXfollowY({@required String x, @required String y}) async {
    DocumentSnapshot docSnap = await userCollection
        .document(x)
        .collection('following')
        .document(y)
        .get();
    return (docSnap.exists);
  }
}
