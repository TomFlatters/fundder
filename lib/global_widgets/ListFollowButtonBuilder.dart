import 'package:flutter/material.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/global_widgets/followButton.dart';

class ListFollowButtonBuilder extends StatelessWidget {
  final String uid;
  final String friendUid;
  ListFollowButtonBuilder(this.uid, this.friendUid);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Align(
            alignment: Alignment.centerRight,
            child: FutureBuilder(
                future: FollowersService(uid: this.uid)
                    .doesXfollowY(x: this.uid, y: this.friendUid),
                builder: (context, initialState) {
                  if (initialState.connectionState == ConnectionState.done &&
                      initialState.data != null) {
                    return MiniFollowButton(initialState.data,
                        profileOwnerId: this.friendUid, myId: this.uid);
                  } else {
                    return Container(
                      height: 0,
                    );
                  }
                })));
  }
}
