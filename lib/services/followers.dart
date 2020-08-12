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
    //do the bookkeeping in the noFollowers and noFollowing fields
    userCollection
        .document(uid)
        .updateData({'noFollowing': FieldValue.increment(1)});
    userCollection
        .document(newlyFollowedId)
        .updateData({'noFollowers': FieldValue.increment(1)});
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
    //do the bookkeeping in the noFollowers and noFollowing fields
    userCollection
        .document(uid)
        .updateData({'noFollowing': FieldValue.increment(-1)});
    userCollection
        .document(recentlyUnfollowedId)
        .updateData({'noFollowers': FieldValue.increment(-1)});
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

class GeneralFollowerServices {
  static CollectionReference userCollection =
      Firestore.instance.collection('users');
  static Future<int> howManyFollowers(String uid) async {
    Map<String, dynamic> doc;
    await userCollection.document(uid).get().then((value) => doc = value.data);

    return (doc.containsKey('noFollowers') ? doc['noFollowers'] : 0);
  }

  static Future<int> howManyFollowing(String uid) async {
    Map<String, dynamic> doc;
    await userCollection.document(uid).get().then((value) => doc = value.data);

    return (doc.containsKey('noFollowing') ? doc['noFollowing'] : 0);
  }

  static Future<String> mapIDtoName(String uid) async {
    //returns corresponding username to uid
    var doc = await userCollection.document(uid).get();
    return doc.data['username'];
  }

///////////////////////////// change after launch to give ten at time kind of thing////////
  static Future<List<String>> idsFollowingUser(String uid) async {
    //returns the user id of all users following user 'uid'
    QuerySnapshot q = await userCollection
        .document(uid)
        .collection('myFollowers')
        .getDocuments();
    //remember that the doc ids are the user ids of the followers]
    return (q.documents.map((e) => e.documentID).toList());
  }

  static Future<List<String>> unamesFollowingUser(String uid) async {
    //return the usernames of all users following the user
    var uids = await GeneralFollowerServices.idsFollowingUser(uid);
    List<String> res = [];
    for (var i; i < uids.length; i++) {
      var uname = await mapIDtoName(uids[i]);
      res.add(uname);
    }
    return res;
  }
}
