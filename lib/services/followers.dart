import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';

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
    return [];
  }

  static Future<List<String>> idsFollowedByUser(String uid) async {
    //returns the user id of all users following user 'uid'
    print("executing idsFollowedByUser");
    CollectionReference followersCollection =
        Firestore.instance.collection('followers');
    DocumentSnapshot docSnap = await followersCollection.document(uid).get();
    if (docSnap.exists) {
      var following = docSnap.data['following'];
      List<String> res = [];

      if (following != null) {
        // return following as List<String>;
        for (var i = 0; i < following.length; i++) {
          print(following[i]);
          res.add(following[i].toString());
        }
        return res;
      } else {
        return [];
      }
    } else {
      return [];
    }
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

  /**Determines the follow relationship status of user x to user y. 
 * returns : `\n`
 * 
 * if (x follows y) returns 'following' `\n`
 * if (x requested to follow y) returns 'follow_requested' `\n`
 * otherwise returns 'not_following' `\n`
 * 
 */

  Future<String> doesXfollowY({@required String x, @required String y}) async {
    HttpsCallable doesXfollowY =
        cloudFunc.getHttpsCallable(functionName: 'doesXfollowY');
    HttpsCallableResult res =
        await doesXfollowY.call(<String, dynamic>{'x': x, 'y': y});
    return res.data['status'];
  }

/**Unfollow 'follower' from 'followee' */
  Future<String> unfollowUser({@required String target}) async {
    HttpsCallable userFollowedSomeone =
        cloudFunc.getHttpsCallable(functionName: 'unfollowXfromY');
    HttpsCallableResult res = await userFollowedSomeone
        .call(<String, dynamic>{'x': uid, 'y': target});
    String status = res.data['status'];
    return status;
  }
}
