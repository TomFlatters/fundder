import 'package:firebase_auth/firebase_auth.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
        Firestore.instance.collection('usernames').document(username).setData({
          username: true,
        });
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
        .collection('usernames')
        .where(username, isEqualTo: true)
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
    await _firebaseMessaging.getToken().then((token) async {
      _firebaseMessaging.deleteInstanceID();
      print(token);
      fcmToken = token;
      await DatabaseService(uid: uid)
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

  // google sign in

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult result = await _auth.signInWithCredential(credential);
    FirebaseUser user = result.user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    String defaultPic =
        'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
    // create a new (firestore) document for the user with corresponding uid

    var docRef = Firestore.instance.collection('users').document(user.uid);

    docRef.get().then((doc) async {
      if (!doc.exists) {
        print('Creating new doc');
        // doc.data() will be undefined in this case
        await DatabaseService(uid: user.uid)
            .registerUserData(user.email, user.displayName, null, defaultPic);
        _getFCMToken(user.uid);
      }
    });

    return 'signInWithGoogle succeeded: $user';
  }

  Future loginWithFacebook(BuildContext context) async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );

        final AuthResult authResult =
            await _auth.signInWithCredential(credential);
        FirebaseUser user = authResult.user;
        assert(user.email != null);
        assert(user.displayName != null);
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);

        String defaultPic =
            'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
        // create a new (firestore) document for the user with corresponding uid

        var docRef = Firestore.instance.collection('users').document(user.uid);

        docRef.get().then((doc) async {
          if (!doc.exists) {
            print('Creating new doc');
            // doc.data() will be undefined in this case
            await DatabaseService(uid: user.uid).registerUserData(
                user.email, user.displayName, null, defaultPic);
            _getFCMToken(user.uid);
          }
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        return 'Cancelled';
        break;
      case FacebookLoginStatus.error:
        return 'result.errorMessage';
        break;
    }
  }

  Future loginWithApple() async {
    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
        clientId: 'com.example.fundderAppleLogIn',
        redirectUri: Uri.parse(
          'https://fundder-c4a64.firebaseapp.com/__/auth/handler',
        ),
      ),
    );

    final oAuthProvider = OAuthProvider(providerId: 'apple.com');
    final credential = oAuthProvider.getCredential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );
    final authResult = await _auth.signInWithCredential(credential);
    final user = authResult.user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    String defaultPic =
        'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
    // create a new (firestore) document for the user with corresponding uid

    var docRef = Firestore.instance.collection('users').document(user.uid);

    docRef.get().then((doc) async {
      if (!doc.exists) {
        print('Creating new doc');
        // doc.data() will be undefined in this case
        await DatabaseService(uid: user.uid)
            .registerUserData(user.email, user.displayName, null, defaultPic);
        _getFCMToken(user.uid);
      }
    });
  }
}
