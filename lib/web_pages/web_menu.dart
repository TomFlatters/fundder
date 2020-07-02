import 'package:flutter/material.dart';
import 'menu_item.dart';
import 'default_button.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/models/user.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/auth.dart';

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
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/about');
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
              Navigator.pushReplacementNamed(context, '/web/feed');
            },
          ),
          MenuItem(
            title: Icon(
              AntDesign.search1,
            ),
            press: () {},
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
            press: () {},
          ),
          MenuItem(
            title: Icon(
              AntDesign.user,
            ),
            press: () {},
          ),
          DefaultButton(
            text: user != null ? "Log out" : "Login / Register",
            press: () async {
              if (user != null) {
                await _auth.signOut();
                /*Navigator.pushReplacementNamed(context, '/web/logging_out');*/
              } else {
                Navigator.pushReplacementNamed(context, '/web/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
