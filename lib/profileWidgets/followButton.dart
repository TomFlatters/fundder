import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/services/followers.dart';

class FollowButton extends StatefulWidget {
  final String profileOwnerId;
  final String myId;
  final FollowersService followersService;
  FollowButton({@required this.profileOwnerId, @required this.myId})
      : followersService = FollowersService(uid: myId);
  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowed;
  void followPressed() {
    if (isFollowed) {
      //already followed, so intention is to unfollow.
      widget.followersService.userUNfollowedSomeone(widget.profileOwnerId);
      setState(() {
        isFollowed = false;
      });
    } else {
      //follow this user as they're not currently followed
      widget.followersService.userFollowedSomeone(widget.profileOwnerId);
      setState(() {
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
