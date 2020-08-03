import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

//NB* A widget that aligns its child within itself and optionally sizes itself based on the child's size.

class PostHeader extends StatelessWidget {
  final String postAuthorId;
  final String postAuthorUserName;

  final String targetCharity;
  PostHeader({this.postAuthorId, this.postAuthorUserName, this.targetCharity});

  @override
  Widget build(BuildContext context) {
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
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(postAuthorUserName,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w600,
                      )))),
          Align(
              alignment: Alignment.centerRight,
              child: Container(
                  margin: EdgeInsets.all(10.0), child: Text(targetCharity))),
        ],
      ),
    );
  }
}
