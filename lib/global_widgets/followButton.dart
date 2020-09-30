import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/services/followers.dart';
import 'package:fundder/helper_classes.dart';

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

/*
class MiniFollowButton extends StatefulWidget {
  final String initialState;
  final String profileOwnerId;
  final String myId;
  final CloudInterfaceForFollowers followersService;
  MiniFollowButton(
    this.initialState, {
    @required this.profileOwnerId,
    @required this.myId,
  }) : followersService = CloudInterfaceForFollowers(myId);
  @override
  _MiniFollowButtonState createState() => _MiniFollowButtonState();
}


class _MiniFollowButtonState extends State<MiniFollowButton> {
  String followStatus;
  @override
  void initState() {
    followStatus = widget.initialState;
    super.initState();
  }


  void followPressed() {
    if (followStatus == 'following') {
      //already followed, so intention is to unfollow.
      widget.followersService.unfollowUser(target: widget.profileOwnerId);
      if (mounted)
        setState(() {
          followStatus = 'not_following';
        });
    } else if (followStatus == 'follow_requested') {
      //do nothing
    
    }
    else {
       widget.followersService.followUser(target: widget.profileOwnerId);
      if (mounted)
        setState(() {
          followStatus = 'following';
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
}*/
