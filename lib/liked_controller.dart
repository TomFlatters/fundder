import 'package:flutter/material.dart';
import 'helper_classes.dart';
import 'view_post_controller.dart';
import 'other_user_profile.dart';

class LikedController extends StatelessWidget {
  final List<String> entries = <String>[
    'started following you',
    'liked your post',
    'donated to your fundraiser'
  ];
  final List<String> buttons = <String>['Follow back', 'View', 'View'];

  LikedController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Activity'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              color: Colors.white,
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(children: <Widget>[
                    Container(
                      height: 60,
                      child: Row(children: <Widget>[
                        Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Container(
                                    child: ProfilePic(
                                        "https://i.imgur.com/BoN9kdC.png", 40),
                                    margin: EdgeInsets.all(10.0),
                                  )),
                              onTap: () {
                                Navigator.pushNamed(context, '/username');
                              },
                            )),
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          fontFamily: 'Muli',
                                        ),
                                        children: [
                                      TextSpan(
                                          text: 'username ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${entries[index % 3]}'),
                                    ])))),
                        Container(
                            width: 110,
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  child: Container(
                                    width: 110,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Text(
                                      "${buttons[index % 3]}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (index % 3 == 0) {
                                      Navigator.pushNamed(context, '/username');
                                    } else {
                                      Navigator.pushNamed(context,
                                          '/post/' + '-MAfLFxe9FtiQZyr4Eti');
                                    }
                                  },
                                ))),
                      ]),
                    )
                  ])));
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 0,
          );
        },
      ),
    );
  }
}
