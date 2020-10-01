import 'package:flutter/material.dart';
import 'fundder_list_tile.dart';
import 'ListFollowButtonBuilder.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/services/followers.dart';
import 'miniButtons.dart';

class FollowRequestTile extends StatefulWidget {
  final String currentUserUid;
  final String displayUserUid;
  FollowRequestTile({this.currentUserUid, this.displayUserUid});
  @override
  _FollowRequestTileState createState() => _FollowRequestTileState();
}

class _FollowRequestTileState extends State<FollowRequestTile> {
  @override
  Widget build(BuildContext context) {
    print('building user tiles');
    return FundderListTile(
        onTap: () async {
          print('/user/' + widget.displayUserUid);
          await Navigator.pushNamed(context, '/user/' + widget.displayUserUid);
          setState(() {});
        },
        profilePicUid: widget.displayUserUid,
        title: FutureBuilder(
            future: GeneralFollowerServices.mapIDtoName(widget.displayUserUid),
            builder: (context, username) {
              if (username.data != null) {
                return Text(username.data.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold));
              } else {
                return Text('User not created',
                    style: TextStyle(fontWeight: FontWeight.normal));
              }
            }),
        trailing: Row(children: [
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
            child: MiniPrimaryFundderButton(
              onPressed: () => {
                CloudInterfaceForFollowers(widget.currentUserUid)
                    .acceptFollowRequest(newFollower: widget.displayUserUid)
              },
              text: 'Confirm',
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: MiniSecondaryFundderButton(
              onPressed: () => {
                CloudInterfaceForFollowers(widget.currentUserUid)
                    .rejectFollowRequest(newFollower: widget.displayUserUid)
              },
              text: 'Delete',
            ),
          ),
        ]));
  }
}
