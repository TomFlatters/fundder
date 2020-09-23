import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/services/followers.dart';

// need a new button for activity feed

class FollowButton extends StatefulWidget {
  /**
   * States can be: 'following', 'follow_requested', 'not_following'
   */
  final String initialState;
  final String profileOwnerId;
  final String myId;
  final CloudInterfaceForFollowers cloudFollowersService;
  final FollowersService followersService;
  FollowButton(
    this.initialState, {
    @required this.profileOwnerId,
    @required this.myId,
  })  : followersService = FollowersService(uid: myId),
        cloudFollowersService = CloudInterfaceForFollowers(myId);
  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  String isFollowed;
  @override
  void initState() {
    isFollowed = widget.initialState;
    super.initState();
  }

  void followPressed() {
    widget.cloudFollowersService.followUser(target: widget.profileOwnerId);
  }

  @override
  Widget build(BuildContext context) {
    return (isFollowed == 'following')
        ? EditFundderButton(
            onPressed: () => {},
            text: 'Unfollow',
          )
        : (isFollowed == 'follow_requested')
            ? EditFundderButton(
                text: 'Follow Requested',
                onPressed: () => {},
              )
            : EditFundderButton(
                text: 'Follow',
                onPressed: () => followPressed(),
              );
  }
}
