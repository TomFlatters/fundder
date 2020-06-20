import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
          title: Container(
            margin: EdgeInsets.only(left:10),
            child: Text('Share to:',style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),),
          ),
          onTap: (){},
        ),
        ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.facebook_messenger)),
          title: Text('Messenger'),
          onTap: (){},
        ), ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome.link)),
          title: Text('Copy Link'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.snapchat_ghost)),
          title: Text('Snapchat'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.whatsapp)),
          title: Text('Whatsapp'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.whatsapp)),
          title: Text('Whatsapp status'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.instagram)),
          title: Text('Instagram'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.instagram)),
          title: Text('Instagram Stories'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(AntDesign.message1)),
          title: Text('SMS'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.facebook_square)),
          title: Text('Facebook'),
          onTap: (){},
        ),ListTile(
          leading: Container(width:30, height:30, child: Icon(FontAwesome5Brands.twitter)),
          title: Text('Twitter'),
          onTap: (){},
        ),
      ],
      );
  }
}


