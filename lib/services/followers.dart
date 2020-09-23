import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';

class FollowersService {
  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference followersCollection =
      Firestore.instance.collection('followers');
  final String uid;
  FollowersService({@required this.uid});

  @Deprecated("userFollowedSomeone")
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

  @Deprecated("userUNfollowedSomeone")
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

/**Returns true if uid x follows uid y, otherwise false */
  Future<bool> doesXfollowY({@required String x, @required String y}) async {
    print("doesXfollowY called");
    DocumentSnapshot docSnap = await followersCollection.document(x).get();
    bool res;
    if (docSnap.exists) {
      var following = docSnap.data['following'];
      if (following is Iterable) {
        res = following.contains(y);
      } else {
        res = false;
      }
    } else {
      res = false;
    }
    print("result of doesXfollowY:" + res.toString());
    return res;
  }
}

@Deprecated("GeneralFollowersServices")
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

/**returns corresponding username to uid*/
  static Future<String> mapIDtoName(String uid) async {
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

  static Future<List<Map>> unamesFollowingUser(String uid) async {
    //return the usernames of all users following the user
    List<String> uids = await GeneralFollowerServices.idsFollowingUser(uid);
    List<Map> res = [];
    if (uids != null) {
      print("uids: " + uids.toString());
      for (int i = 0; i < uids.length; i++) {
        var uname = await mapIDtoName(uids[i]);
        res.add(<String, String>{"username": uname, "uid": uids[i]});
      }
    }
    return res;
  }

  static Future<List<String>> idsFollowedByUser(String uid) async {
    //returns the user id of all users following user 'uid'
    QuerySnapshot q = await userCollection
        .document(uid)
        .collection('following')
        .getDocuments();
    //remember that the doc ids are the user ids of the followers]
    return (q.documents.map((e) => e.documentID).toList());
  }

  static Future<List<Map>> unamesFollowedByUser(String uid) async {
    //return the usernames of all users following the user
    List<String> uids = await GeneralFollowerServices.idsFollowedByUser(uid);
    List<Map> res = [];
    if (uids != null) {
      print("uids: " + uids.toString());
      for (int i = 0; i < uids.length; i++) {
        var uname = await mapIDtoName(uids[i]);
        res.add(<String, String>{"username": uname, "uid": uids[i]});
      }
    }
    return res;
  }
}

class CloudInterfaceForFollowers {
  final uid;
  final cloudFunc = CloudFunctions.instance
      .useFunctionsEmulator(origin: 'http://10.0.2.2:5001');

  CloudInterfaceForFollowers(this.uid);

  /**Interacts with cloud functions to request to follow a user.
   * If the user is private, then a successful status result will be 'requested'.
   * If the user is public, then a successful response is 'nowFollowing'
   * Anything else is a failed response and should be handled.
   */
  Future<String> followUser({@required String target}) async {
    HttpsCallable userFollowedSomeone =
        cloudFunc.getHttpsCallable(functionName: 'userFollowedSomeone');
    HttpsCallableResult res = await userFollowedSomeone
        .call(<String, dynamic>{'follower': uid, 'followee': target});
    String status = res.data['status'];
    return status;
  }
}
