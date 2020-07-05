import 'package:flutter/material.dart';
import 'menu_item.dart';
import 'default_button.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/models/user.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/extensions/hover_extensions.dart';

class WebMenu extends StatelessWidget {
  final AuthService _auth = AuthService();
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            child: Image.asset(
              "assets/images/Fundder_logo.png",
              height: 50,
              alignment: Alignment.topCenter,
            ).showCursorOnHover,
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          SizedBox(width: 10),
          Text(
            'Fundder',
            style: TextStyle(fontSize: 22, fontFamily: 'Roboto Mono'),
          ),
          Spacer(),
          MenuItem(
            title: Icon(
              AntDesign.home,
            ),
            press: () {
              Navigator.pushNamed(context, '/web/feed');
            },
          ),
          MenuItem(
            title: Icon(
              AntDesign.search1,
            ),
            press: () {
              Navigator.pushNamed(context, '/web/search');
            },
          ),
          MenuItem(
            title: Icon(
              AntDesign.plussquareo,
            ),
            press: () {
              Navigator.pushNamed(context, '/addpost');
            },
          ),
          MenuItem(
            title: Icon(
              AntDesign.hearto,
            ),
            press: () {
              Navigator.pushNamed(context, '/web/activity');
            },
          ),
          MenuItem(
            title: Icon(
              AntDesign.user,
            ),
            press: () {
              Navigator.pushNamed(context, '/web/profile');
            },
          ),
          DefaultButton(
            text: user != null ? "Log out" : "Login / Register",
            press: () async {
              if (user != null) {
                await _auth.signOut().then((value) {
                  Navigator.pushNamed(context, '/web/login');
                });
                /*Navigator.pushReplacementNamed(context, '/web/logging_out');*/
              } else {
                Navigator.pushNamed(context, '/web/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
