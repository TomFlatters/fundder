import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SearchDescriptor extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView(padding: const EdgeInsets.only(top: 10.0), children: [
          Center(
            child: Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(
                      Radius.circular(10.0),
                    )),
                padding: EdgeInsets.only(top: 100),
                child: Column(children: [
                  Icon(
                    AntDesign.search1,
                    color: Colors.grey[300],
                    size: MediaQuery.of(context).size.width / 4,
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          top: 30, left: 40, right: 40, bottom: 150),
                      child: Text(
                        'Search for posts by hashtag or for users by username',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontFamily: 'Founders Grotesk'),
                      )),
                ])),
          )
        ]));
  }
}
