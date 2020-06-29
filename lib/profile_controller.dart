import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'feed.dart';
import 'edit_profile_controller.dart';
import 'view_followers_controller.dart';
import 'profile_actions_view.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'models/post.dart';
import 'package:provider/provider.dart';
import 'helper_classes.dart';

class ProfileController extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
  ProfileController();
}

class _ProfileState extends State<ProfileController> with SingleTickerProviderStateMixin {

  final AuthService _auth = AuthService();

  TabController _tabController;
  String _username = "Username";
  String _name = "Name";
  String _uid;
  String _email = "Email";

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _retrieveUser();
    super.initState();
  }

  void _retrieveUser() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance.collection("users").document(firebaseUser.uid).get().then((value){
      setState(() {
        _uid = firebaseUser.uid;
        _name = value.data["name"];
        _username = value.data["username"];
        _email = value.data["email"];
      });
    });
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }


@override
Widget build(BuildContext context) { 
  final user = Provider.of<User>(context);
  // print(user.uid);
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(_username),
      actions: <Widget>[
        FlatButton(
          onPressed: () /*async {
            await _auth.signOut();
          }*/ {_showOptions();}, 
          child: Icon(AntDesign.ellipsis1),
        )
      ],
    ),
    body: ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 20, bottom:10),
          alignment: Alignment.center,
          child: Container(
            child: ProfilePic("https://i.imgur.com/BoN9kdC.png", 90),
            margin: EdgeInsets.all(10.0),            
          ),
        ), Center(
          child: Text(_name),
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
                onTap: () {Navigator.of(context).push(_viewFollowers());},
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
              TabBar(
                tabs: [Tab(text: 'Posts'), Tab(text: 'Liked')],
                controller: _tabController,
                ),
                [FeedView('user', _username, Colors.black, DatabaseService(uid: user.uid).postsByUser(user.uid)),
                FeedView('user', _username, Colors.blue, DatabaseService(uid: user.uid).postsByUser(user.uid)),][_tabController.index]
              /*ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 1000),
                child: TabBarView(
                    children: [
                      FeedView('user', Colors.black),
                      FeedView('user', Colors.black),
                      ],
                  )
              )*/
            ],
          ), 
        )
      ]
    ),
  );
 }

  void _showOptions() {
  showModalBottomSheet(
    context: context, 
    builder: (context) {
      return ProfileActions();
    }
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