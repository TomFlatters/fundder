import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SearchDescriptor extends StatelessWidget {
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.width,
      child: Center(
          child: Container(
        child: Column(children: [
          Icon(
            AntDesign.search1,
            color: Colors.grey[300],
            size: MediaQuery.of(context).size.width / 2,
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              child: Text(
                'Search for users by username or for posts by keyword',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              )),
        ]),
      )),
    ));
  }
}
