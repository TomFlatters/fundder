import 'package:flutter/material.dart';
import 'fundder_list_tile.dart';
import 'ListFollowButtonBuilder.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/services/followers.dart';

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
          GestureDetector(
            child: Container(
                padding:
                    EdgeInsets.only(top: 5, bottom: 2, left: 10, right: 10),
                margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: HexColor('ff6b6c')),
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                )),
            onTap: () => {
              CloudInterfaceForFollowers(widget.currentUserUid)
                  .acceptFollowRequest(newFollower: widget.displayUserUid)
            },
          ),
          GestureDetector(
            child: Container(
                padding: EdgeInsets.only(top: 5, bottom: 2, left: 5, right: 5),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.grey, width: 1),
                    color: Colors.white),
                child: Center(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )),
            onTap: () => {
              CloudInterfaceForFollowers(widget.currentUserUid)
                  .rejectFollowRequest(newFollower: widget.displayUserUid)
            },
          ),
        ]));
  }
}
