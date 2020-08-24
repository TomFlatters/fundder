import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';

//NB* A widget that aligns its child within itself and optionally sizes itself based on the child's size.

class PostHeader extends StatelessWidget {
  final String postAuthorId;
  final String postAuthorUserName;

  final String targetCharity;
  final String postStatus;
  final String charityLogo;
  PostHeader(
      {this.postAuthorId,
      this.postAuthorUserName,
      this.targetCharity,
      this.postStatus,
      this.charityLogo});

  @override
  Widget build(BuildContext context) {
    print('charity logo: ' + this.charityLogo);
    return Container(
      height: 60,
      child: Row(
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      child: ProfilePic(postAuthorId, 40),
                      margin: EdgeInsets.all(10.0),
                    )),
                onTap: () {
                  print('/user/' + postAuthorId);
                  Navigator.pushNamed(context, '/user/' + postAuthorId);
                },
              )),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(postAuthorUserName,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                  ))),
          Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      height: 60,
                      //color: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.all(10.0),
                      child: CachedNetworkImage(
                        imageUrl: this.charityLogo,
                        //color: Colors.red,
                      )))),
          this.postStatus == 'done'
              ? Row(children: [
                  Icon(
                    Ionicons.ios_checkmark_circle,
                    color: HexColor('ff6b6c'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  )
                ])
              : Container(),
        ],
      ),
    );
  }
}
