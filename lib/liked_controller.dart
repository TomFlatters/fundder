import 'package:flutter/material.dart';
import 'helper_classes.dart';
import 'view_post_controller.dart';

class LikedController extends StatelessWidget {

   final List<String> entries = <String>['username_long started following you', 'username liked your post', 'username donated to your fundraiser'];
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
                margin: EdgeInsets.symmetric(horizontal:10),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60,
                      child: Row(
                        children: <Widget>[Align(
                          alignment: Alignment.centerLeft,
                          child: AspectRatio(
                            aspectRatio: 1/1,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      "https://i.imgur.com/BoN9kdC.png")
                                )
                              ),
                              margin: EdgeInsets.all(10.0),            
                            )
                          )
                        ), Expanded(child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${entries[index%3]}'
                          )
                        )
                        ), Container(
                          width: 110,
                          child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            child: Container(
                              width: 110,
                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Text(
                                "${buttons[index%3]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              onTap: () {Navigator.of(context).push(_createRoute());},
                          )
                          )
                        ),
                        ],
                      ),
                    ),
                  ],
                )
              )
            );
          },
          separatorBuilder: (BuildContext context, int index){
            return SizedBox(
              height: 10,
            );
          },
        ),
    );
 }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewPost(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}