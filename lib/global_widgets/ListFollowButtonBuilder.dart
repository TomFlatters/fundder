import 'package:flutter/material.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/global_widgets/followButton.dart';
import 'miniButtons.dart';

class ListFollowButtonBuilder extends StatelessWidget {
  final String uid;
  final String friendUid;
  ListFollowButtonBuilder(this.uid, this.friendUid);

  @override
  Widget build(BuildContext context) {
    bool isFollower = false;
    return FutureBuilder(
      future: CloudInterfaceForFollowers(this.uid)
          .doesXfollowY(x: this.uid, y: this.friendUid),
      builder: (context, initialState) {
        if (initialState.connectionState == ConnectionState.done &&
            initialState.data != null) {
          isFollower = (initialState.data == "following");
          print("this person is a follower: ${isFollower.toString()}");

          return MiniFollowButton(initialState.data,
              profileOwnerId: this.friendUid, myId: this.uid);
        } else {
          return MiniSecondaryFundderButton(text: "", onPressed: () {});
        }
      },
    );
  }
}
