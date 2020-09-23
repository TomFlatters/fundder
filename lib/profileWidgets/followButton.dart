import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/services/followers.dart';

// need a new button for activity feed

//NOTE: This button is integrated with a stream so no need for it to be a Stateful
//widget!!

//There are mechanisms coded to use the state better

class FollowButton extends StatelessWidget {
  final String isFollowed;
  final String profileOwnerId;
  final String myId;
  final CloudInterfaceForFollowers cloudFollowersService;

  FollowButton(
    this.isFollowed, {
    @required this.profileOwnerId,
    @required this.myId,
  }) : cloudFollowersService = CloudInterfaceForFollowers(myId);
  @override
  Widget build(BuildContext context) {
    if (isFollowed == 'following') {
      return EditFundderButton(
        onPressed: () =>
            {cloudFollowersService.unfollowUser(target: profileOwnerId)},
        text: 'Unfollow',
      );
    } else if (isFollowed == 'follow_requested') {
      return EditFundderButton(
        text: 'Follow Requested',
        onPressed: () => {},
      );
    } else {
      return EditFundderButton(
        text: 'Follow',
        onPressed: () =>
            cloudFollowersService.followUser(target: profileOwnerId),
      );
    }
  }
}
