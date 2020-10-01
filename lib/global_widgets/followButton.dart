import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/helper_classes.dart';
import 'miniButtons.dart';

// need a new button for activity feed

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
        text: 'Cancel Follow Request',
        onPressed: () async {
          var followersCollection = Firestore.instance.collection('followers');
          var userCollection = Firestore.instance.collection('users');
          await followersCollection.document(profileOwnerId).updateData({
            'requestedToFollowMe': FieldValue.arrayRemove([myId])
          });
          await userCollection.document(profileOwnerId).setData(
              {'noFollowRequestsForMe': FieldValue.increment(-1)},
              merge: true);
        },
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

class MiniFollowButton extends StatelessWidget {
  final String isFollowed;
  final String profileOwnerId;
  final String myId;
  final CloudInterfaceForFollowers cloudFollowersService;

  MiniFollowButton(
    this.isFollowed, {
    @required this.profileOwnerId,
    @required this.myId,
  }) : cloudFollowersService = CloudInterfaceForFollowers(myId);
  @override
  Widget build(BuildContext context) {
    if (isFollowed == 'following') {
      return MiniSecondaryFundderButton(
        onPressed: () =>
            {cloudFollowersService.unfollowUser(target: profileOwnerId)},
        text: 'Unfollow',
      );
    } else if (isFollowed == 'follow_requested') {
      return MiniSecondaryFundderButton(
        text: 'Requested',
        onPressed: () {},
      );
    } else {
      return MiniPrimaryFundderButton(
        text: 'Follow',
        onPressed: () =>
            cloudFollowersService.followUser(target: profileOwnerId),
      );
    }
  }
}
