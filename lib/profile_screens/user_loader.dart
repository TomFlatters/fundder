import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'profile_controller.dart';
import 'package:fundder/shared/loading.dart';

class UserLoader extends StatelessWidget {
  final String uid;
  UserLoader({@required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DatabaseService(uid: this.uid).userStream(this.uid),
        // widget.feedChoice == 'user'
        //   ? Firestore.instance.collection("posts").where("author", isEqualTo: widget.identifier).snapshots()
        //   : Firestore.instance.collection("posts").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            DocumentSnapshot doc = snapshot.data;
            if (doc.data != null) {
              User user =
                  DatabaseService(uid: this.uid).userDataFromSnapshot(doc);
              return ProfileController(user: user);
            } else {
              return Scaffold(
                appBar: AppBar(),
                body: Text('User not fully created'),
              );
            }
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(),
                body: Text('Cannot find user'),
              );
            } else {
              return Loading();
            }
          }
        });
  }
}
