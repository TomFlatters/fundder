import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/helper_classes.dart';

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

class MiniFollowButton extends StatefulWidget {
  final bool initialState;
  final String profileOwnerId;
  final String myId;
  final FollowersService followersService;
  MiniFollowButton(
    this.initialState, {
    @required this.profileOwnerId,
    @required this.myId,
  }) : followersService = FollowersService(uid: myId);
  @override
  _MiniFollowButtonState createState() => _MiniFollowButtonState(initialState);
}

class _MiniFollowButtonState extends State<MiniFollowButton> {
  bool isFollowed = false;
  _MiniFollowButtonState(this.isFollowed);
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
        setState(() {
          isFollowed = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (isFollowed)
        ? FlatButton(
            child: Container(
                width: 100,
                padding: EdgeInsets.only(top: 5, bottom: 2, left: 5, right: 5),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.grey, width: 1),
                    color: Colors.white),
                child: Center(
                  child: Text(
                    'Unfollow',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )),
            onPressed: () => followPressed(),
          )
        : FlatButton(
            child: Container(
                width: 100,
                padding: EdgeInsets.only(top: 5, bottom: 2, left: 5, right: 5),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: HexColor('ff6b6c')),
                child: Center(
                  child: Text(
                    'Follow',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                )),
            onPressed: () => followPressed(),
          );
  }
}
