import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';

class SharePost extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF737373),
      height: 350,
      child: Container(
        child: _buildBottomNavigationMenu(),
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

  ListView _buildBottomNavigationMenu() {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/007-messenger.png')),
          title: Text('Messenger'),
          onTap: (){},
        ), ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/009-link.png')),
          title: Text('Copy Link'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/003-snapchat.png')),
          title: Text('Snapchat'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/004-whatsapp.png')),
          title: Text('Whatsapp'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/004-whatsapp.png')),
          title: Text('Whatsapp status'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/005-instagram.png')),
          title: Text('Instagram'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/005-instagram.png')),
          title: Text('Instagram Stories'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/008-comment.png')),
          title: Text('SMS'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/001-facebook.png')),
          title: Text('Facebook'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Image.asset('assets/images/006-twitter.png')),
          title: Text('Twitter'),
          onTap: (){},
        ),
      ],
      );
  }
}


