import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'ListFollowButtonBuilder.dart';

class FundderListTile extends StatelessWidget {
  final Function onTap;
  final String profilePicUid;
  final Widget title;
  final Widget trailing;
  FundderListTile({this.onTap, this.profilePicUid, this.title, this.trailing});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: this.onTap,
        child: Container(
            padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
            color: Colors.white,
            child: Row(children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: ProfilePic(this.profilePicUid, 40),
                  margin: EdgeInsets.all(10.0),
                ),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft, child: this.title)),
              this.trailing != null
                  ? this.trailing
                  : Container(
                      width: 0,
                    )
            ])));
  }
}
