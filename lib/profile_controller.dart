import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';

class ProfileController extends StatelessWidget {

ProfileController();

final AuthService _auth = AuthService();

@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile'),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () async {
              await _auth.signOut();
            }, 
            icon: Icon(Icons.person), 
            label: Text('Log Out'))
        ],
      ),
    );
 }
}