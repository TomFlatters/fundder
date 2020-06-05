import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'feed.dart';
import 'edit_profile_controller.dart';
import 'view_followers_controller.dart';

class ProfileController extends StatelessWidget {

ProfileController();

final AuthService _auth = AuthService();

@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Name'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              await _auth.signOut();
            }, 
            child: Text('Log Out'))
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20, bottom:10),
            alignment: Alignment.center,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image:  new NetworkImage(
                    "https://i.imgur.com/BoN9kdC.png")
                )
              ),
            ),
          ), Center(
            child: Text("@username"),
          ), Container(
            margin: EdgeInsets.symmetric(horizontal:50, vertical: 20),
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded( child:GestureDetector(
                  child: Column( children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    child: Text("54", 
                      style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                  Expanded( child:Container(
                    alignment: Alignment.bottomCenter,
                    child: Text("Following"),
                  )),
                  ],),
                  onTap: () {Navigator.of(context).push(_viewFollowers());},
                )),
                Expanded( child:GestureDetector(
                  child: Column( children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    child: Text("106", 
                      style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                  Expanded( child:Container(
                    alignment: Alignment.bottomCenter,
                    child: Text("Followers"),
                  )),
                  ],),
                  onTap: () {Navigator.of(context).push(_editProfile());},
                )),
                Expanded(
                  child: Column( children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    child: Text("£54", 
                      style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                  Expanded( child:Container(
                    alignment: Alignment.bottomCenter,
                    child: Text("Raised"),
                  )),
                  ],)
                ),
              ],
            )
          ),  GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: EdgeInsets.only(left: 70, right:70, bottom: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                "Edit Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            onTap: (){ Navigator.of(context).push(_editProfile());
            }
          ), DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Column(
              children: [
                TabBar(tabs: [Tab(text: 'Posts'), Tab(text: 'Liked')]),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 1000),
                  child: TabBarView(
                      children: [
                        FeedView('user', Colors.black),
                        FeedView('user', Colors.black),
                        ],
                    )
                )
              ],
            ), 
          )
        ]
      ),
    );
 }
}

Route _editProfile() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => EditProfile(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}

Route _viewFollowers() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewFollowers(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}