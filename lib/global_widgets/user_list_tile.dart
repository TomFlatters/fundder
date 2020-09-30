import 'package:flutter/material.dart';
import 'fundder_list_tile.dart';
import 'ListFollowButtonBuilder.dart';

class UserListTile extends StatefulWidget {
  final String currentUserUid;
  final String displayUserUid;
  final String displayUserUsername;
  UserListTile(
      {this.currentUserUid, this.displayUserUid, this.displayUserUsername});
  @override
  _UserListTileState createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  @override
  Widget build(BuildContext context) {
    return FundderListTile(
      onTap: () async {
        print('/user/' + widget.displayUserUid);
        await Navigator.pushNamed(context, '/user/' + widget.displayUserUid);
        setState(() {});
      },
      profilePicUid: widget.displayUserUid,
      title: widget.displayUserUsername,
      trailing:
          ListFollowButtonBuilder(widget.currentUserUid, widget.displayUserUid),
    );
  }
}
