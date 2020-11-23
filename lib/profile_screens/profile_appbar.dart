// // WORK IN PROGRESS: THIS FILE NOT USED

// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// class ProfileSelfAppBar extends StatefulWidget implements PreferredSizeWidget {
//   ProfileSelfAppBar({Key key}) : preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

//   @override
//   final Size preferredSize;

//   @override
//   _CustomAppBarState createState() => _CustomAppBarState();
// }

// class _CustomAppBarState extends State<ProfileSelfAppBar>{
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//                 centerTitle: true,
//                 title: Text(widget.user.username),
//                 leading: GestureDetector(
//                     onTap: () {
//                       Navigator.pushNamed(context, '/challengefriend');
//                     },
//                     child: new Icon(MdiIcons.sword)),
//                 actions: widget.user.uid == firebaseUser.uid
//                     ? <Widget>[
//                         IconButton(
//                           onPressed: () {
//                             _showOptions();
//                           },
//                           icon: Icon(AntDesign.ellipsis1),
//                         )
//                       ]
//                     : <Widget>[
//                         IconButton(
//                             icon: Icon(SimpleLineIcons.bubble),
//                             onPressed: () {
//                               Navigator.pushNamed(
//                                   context,
//                                   '/chatroom/' +
//                                       widget.user.uid +
//                                       '/' +
//                                       widget.user.username);
//                             })
//                       ])
//   }
// }
