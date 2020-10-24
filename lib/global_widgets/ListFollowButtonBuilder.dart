import 'package:flutter/material.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/global_widgets/followButton.dart';
import 'miniButtons.dart';
import 'package:fundder/shared/loading.dart';
import 'package:flutter/cupertino.dart';

class ListFollowButtonBuilder extends StatefulWidget {
  final String uid;
  final String friendUid;
  ListFollowButtonBuilder(this.uid, this.friendUid);
  @override
  _ListFollowButtonBuilderState createState() =>
      _ListFollowButtonBuilderState();
}

class _ListFollowButtonBuilderState extends State<ListFollowButtonBuilder> {
  @override
  Widget build(BuildContext context) {
    bool loading = false;
    bool isFollower = false;
    return FutureBuilder(
      future: CloudInterfaceForFollowers(widget.uid)
          .doesXfollowY(x: widget.uid, y: widget.friendUid),
      builder: (context, initialState) {
        if (initialState.connectionState == ConnectionState.done &&
            initialState.data != null &&
            loading == false) {
          isFollower = (initialState.data == "following");
          print("this person is a follower: ${isFollower.toString()}");

          return MiniFollowButton(
            initialState.data,
            profileOwnerId: widget.friendUid,
            myId: widget.uid,
            setFutureBuilderState: () {
              setState(() {
                loading = true;
              });
            },
          );
        } else {
          return Container(width: 100, child: CupertinoActivityIndicator());
        }
      },
    );
  }
}
