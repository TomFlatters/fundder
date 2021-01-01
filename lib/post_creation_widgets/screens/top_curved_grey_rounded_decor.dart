import 'package:flutter/material.dart';

class GreyGapRounded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: Colors.white,
        ),
        margin: EdgeInsets.only(top: 10),
      ),
    );
  }
}
