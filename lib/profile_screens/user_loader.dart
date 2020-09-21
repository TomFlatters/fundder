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
          if (snapshot.hasData) {
            User user = DatabaseService(uid: this.uid)
                .userDataFromSnapshot(snapshot.data);
            return ProfileController(user: user);
          } else {
            return Loading();
          }
        });
  }
}
