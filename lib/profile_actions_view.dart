import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ProfileActions extends StatelessWidget{

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF737373),
      height: 350,
      child: Container(
        child: _buildBottomNavigationMenu(context),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            ),
        ),
      ),
    );
  }

  ListView _buildBottomNavigationMenu(context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(MaterialCommunityIcons.logout),
          title: Text('Logout'),
          onTap: () async {
              await _auth.signOut();
              Navigator.pop(context);
            },
        ),
        ListTile(
          leading: Icon(FontAwesome.money),
          title: Text('Payments'),
          onTap: () {
            },
        ),
                ListTile(
          leading: Icon(Feather.activity),
          title: Text('Your Activity'),
          onTap: () {
            },
        ),
                ListTile(
          leading: Icon(MaterialCommunityIcons.account_badge_outline),
          title: Text('Account'),
          onTap: () {
            },
        ),
      ],
      );
  }
}