import 'package:firebase_auth/firebase_auth.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  String fcmToken;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on (a subset of) FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  // define methods to interact with firebase auth

  // auth change user stream (returns Users)
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in w/ email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      _getFCMToken(user.uid);
      return 'Success';
    } catch (e) {
      print(e.toString());
      if (e.message != null) {
        return e.message;
      } else {
        return e.toString();
      }
    }
  }

  // register w/ email & password
  Future registerWithEmailPasswordUsername(
      String email, String password, String username) async {
    if (await usernameUnique(username) == true) {
      try {
        AuthResult result = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        FirebaseUser user = result.user;
        user.sendEmailVerification();
        String defaultPic =
            'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
        // create a new (firestore) document for the user with corresponding uid
        await DatabaseService(uid: user.uid)
            .registerUserData(email, username, null, defaultPic);
        _getFCMToken(user.uid);
        // ADD: user sets username
        return 'Success';
      } catch (e) {
        print(e.toString());
        if (e.message != null) {
          return e.message;
        } else {
          return e.toString();
        }
      }
    } else {
      return 'Username is taken';
    }
  }

  Future<bool> usernameUnique(String username) async {
    final snapshot = await Firestore.instance
        .collection('users')
        .where("username", isEqualTo: username)
        .getDocuments();
    if (snapshot == null || snapshot.documents.isEmpty) {
      return true; //username is unique.
    } else {
      return false; //username exists.
    }
  }

  void _getFCMToken(String uid) {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch called');
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume called');
      },
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called');
      },
    );
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Hello');
    });
    _firebaseMessaging.getToken().then((token) {
      print(token);
      fcmToken = token;
      DatabaseService(uid: uid)
          .addFCMToken(fcmToken); // Print the Token in Console
    });
  }

  Future _removeFCMToken() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) {
      _firebaseMessaging.deleteInstanceID();
      print(token);
      fcmToken = token;
      DatabaseService(uid: uid)
          .removeFCMToken(fcmToken); // Print the Token in Console
    });
  }

  Future forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent';
    } catch (e) {
      if (e.message != null) {
        return e.message;
      } else {
        return e.toString();
      }
    }
  }

  // ... add more for Google and Facebook

  // sign out
  Future signOut() async {
    try {
      await _removeFCMToken();
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
