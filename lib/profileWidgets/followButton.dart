import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/services/followers.dart';

// need a new button for activity feed

class FollowButton extends StatefulWidget {
  final bool initialState;
  final String profileOwnerId;
  final String myId;
  final FollowersService followersService;
  FollowButton(
    this.initialState, {
    @required this.profileOwnerId,
    @required this.myId,
  }) : followersService = FollowersService(uid: myId);
  @override
  _FollowButtonState createState() => _FollowButtonState(initialState);
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowed = false;
  _FollowButtonState(this.isFollowed);
  void followPressed() {
    if (isFollowed) {
      //already followed, so intention is to unfollow.
      widget.followersService.userUNfollowedSomeone(widget.profileOwnerId);
      if (mounted)
        setState(() {
          isFollowed = false;
        });
    } else {
      //follow this user as they're not currently followed
      widget.followersService.userFollowedSomeone(widget.profileOwnerId);
      if (mounted)
        (() {
          isFollowed = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (isFollowed)
        ? EditFundderButton(
            onPressed: () => followPressed(),
            text: 'Unfollow',
          )
        : EditFundderButton(
            text: 'Follow',
            onPressed: () => followPressed(),
          );
  }
}
