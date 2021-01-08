import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

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
    if (doc.data != null) {
      return doc.data['username'];
    } else {
      return '';
    }
  }

///////////////////////////// change after launch to give ten at time kind of thing////////
  static Future<List<String>> idsFollowingUser(String uid) async {
    //returns the user id of all users following user 'uid'
    print("executing idsFollowingByUser");
    CollectionReference followersCollection =
        Firestore.instance.collection('followers');
    DocumentSnapshot docSnap = await followersCollection.document(uid).get();
    if (docSnap.exists) {
      var followers = docSnap.data['followers'];
      List<String> res = [];

      if (followers != null) {
        // return following as List<String>;
        for (var i = 0; i < followers.length; i++) {
          print(followers[i]);
          res.add(followers[i].toString());
        }
        return res;
      } else {
        return [];
      }
    } else {
      return [];
    }
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

  Future<List> facebookFriendsUnames(
      List<String> facebookIdList, String uid) async {
    QuerySnapshot q = await userCollection
        .where('facebookId', whereIn: facebookIdList)
        .getDocuments();
    List l = q.documents
        .map((e) => {'uid': e.documentID, 'username': e.data['username']})
        .toList();
    return l;
  }
}

/**Note that this service no longer interfaces with the cloud */
class CloudInterfaceForFollowers {
  final uid;
  final cloudFunc = CloudFunctions.instance
      .useFunctionsEmulator(origin: 'http://10.0.2.2:5001');
  final CollectionReference _followersCollection =
      Firestore.instance.collection('followers');
  final CollectionReference _usersCollection =
      Firestore.instance.collection('users');

  CloudInterfaceForFollowers(this.uid);

/**takes the id of the prospective followee
 * and id follower and the 'isPrivate' status of followee in that order and follows or requests follow.
 * Returns the status of the outcome.  */

  Future<String> _initiateFollow(followee, follower, followeeIsPrivate) async {
    if (followeeIsPrivate) {
      _followersCollection.document(followee).setData({
        'requestedToFollowMe': FieldValue.arrayUnion([follower])
      }, merge: true);
      var followerDoc = await _followersCollection.document(follower).get();
      if (!followerDoc.exists) {
        _followersCollection
            .document(follower)
            .setData({'following': []}, merge: true);
      }

      _usersCollection.document(followee).setData(
          {'noFollowRequestsForMe': FieldValue.increment(1)},
          merge: true);
      return "requested";
    } else {
      _followersCollection.document(followee).setData({
        'followers': FieldValue.arrayUnion([follower])
      }, merge: true);
      _followersCollection.document(follower).setData({
        'following': FieldValue.arrayUnion([followee])
      }, merge: true);
      _usersCollection
          .document(follower)
          .setData({'noFollowing': FieldValue.increment(1)}, merge: true);
      _usersCollection
          .document(followee)
          .setData({'noFollowers': FieldValue.increment(1)}, merge: true);
      return "nowFollowing";
    }
  }

  /**Interacts with cloud functions to request to follow a user.
   * If the user is private, then a successful status result will be 'requested'.
   * If the user is public, then a successful response is 'nowFollowing'
   * Anything else is a failed response and should be handled.
   * 
   * NOTE: no longer interacts with cloud function massive rip 
   * The things we do for....nothing really THE END
   */
  Future<String> followUser({@required String target}) async {
    var userDoc =
        await Firestore.instance.collection('users').document(target).get();
    var followeeIsPrivate = (userDoc.data['isPrivate'] == null)
        ? false
        : userDoc.data['isPrivate'] == true;
    var status = await _initiateFollow(target, uid, followeeIsPrivate);
    String username = await GeneralFollowerServices.mapIDtoName(uid);
    if (userDoc.data['isPrivate'] != true) {
      await Firestore.instance.collection('users/$target/activity').add({
        'timestamp': Timestamp.now(),
        'category': 'new follower',
        'docLiker': uid,
        'docLikerUsername': username,
        'postId': uid,
        'seen': false
      });
    }
    return status;

    /*
    HttpsCallable userFollowedSomeone =
        cloudFunc.getHttpsCallable(functionName: 'userFollowedSomeone');
    HttpsCallableResult res = await userFollowedSomeone
        .call(<String, dynamic>{'follower': uid, 'followee': target});
    var status = res.data['status'];
    return status.toString();
    */
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
    var xDoc = await _followersCollection.document(x).get();
    if (!xDoc.exists) {
      return 'not_following';
    }

    if (xDoc.data['following'] == null) {
      return 'not_following';
    }

    var xFollowing = xDoc.data['following'];
    if (xFollowing.contains(y)) {
      return 'following';
    } else {
      //doesn't follow so either requested to follow or not following
      var yDoc = await _followersCollection.document(y).get();
      if (!yDoc.exists) {
        return 'not_following';
      }
      if (yDoc.data["requestedToFollowMe"] != null) {
        var yRequested = yDoc.data["requestedToFollowMe"];
        if (yRequested.contains(x)) {
          return 'follow_requested';
        }
      }
      return 'not_following';
    }
    /*
    HttpsCallable doesXfollowY =
        cloudFunc.getHttpsCallable(functionName: 'doesXfollowY');
    HttpsCallableResult res =
        await doesXfollowY.call(<String, dynamic>{'x': x, 'y': y});
    return res.data['status'];
    */
  }

/**Unfollow 'follower' from 'followee' */
  Future<String> unfollowUser({@required String target}) async {
    _followersCollection.document(target).setData({
      'followers': FieldValue.arrayRemove([uid])
    }, merge: true);
    _followersCollection.document(uid).setData({
      'following': FieldValue.arrayRemove([target])
    }, merge: true);
    _usersCollection
        .document(uid)
        .setData({'noFollowing': FieldValue.increment(-1)}, merge: true);
    _usersCollection
        .document(target)
        .setData({'noFollowers': FieldValue.increment(-1)}, merge: true);
    return 'removed';

    /*
    HttpsCallable userFollowedSomeone =
        cloudFunc.getHttpsCallable(functionName: 'unfollowXfromY');
    HttpsCallableResult res = await userFollowedSomeone
        .call(<String, dynamic>{'x': uid, 'y': target});
    String status = res.data['status'];
    return status;
    */
  }

/**Removes newFollower from 'requestedToFollowMe' and adds him to  */
  Future acceptFollowRequest({@required newFollower}) async {
    await _followersCollection.document(uid).setData({
      'requestedToFollowMe': FieldValue.arrayRemove([newFollower])
    }, merge: true);

    await _initiateFollow(uid, newFollower, false);
    String username = await GeneralFollowerServices.mapIDtoName(uid);
    String followerUsername =
        await GeneralFollowerServices.mapIDtoName(newFollower);

    await Firestore.instance.collection('users/$newFollower/activity').add({
      'timestamp': Timestamp.now(),
      'category': 'request accepted',
      'docLiker': uid,
      'docLikerUsername': username,
      'postId': uid,
      'seen': false
    });

    await Firestore.instance.collection('users/$uid/activity').add({
      'timestamp': Timestamp.now(),
      'category': 'new follower',
      'docLiker': newFollower,
      'docLikerUsername': followerUsername,
      'postId': newFollower,
      'seen': false
    });
  }

  Future rejectFollowRequest({@required newFollower}) async {
    print('reject folow request uid: ' + newFollower);
    await _followersCollection.document(uid).setData({
      'requestedToFollowMe': FieldValue.arrayRemove([newFollower])
    }, merge: true);
  }
}
