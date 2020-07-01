import 'package:flutter/material.dart';
import 'menu_item.dart';
import 'default_button.dart';

class WebMenu extends StatelessWidget {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          Image.asset(
            "assets/images/Fundder_logo.png",
            height: 50,
            alignment: Alignment.topCenter,
          ),
          SizedBox(width: 10),
          Text(
            'Fundder',
            style: TextStyle(fontSize: 22, fontFamily: 'Roboto Mono'),
          ),
          Spacer(),
          MenuItem(
            title: "Home",
            press: () {},
          ),
          MenuItem(
            title: "about",
            press: () {},
          ),
          MenuItem(
            title: "Pricing",
            press: () {},
          ),
          MenuItem(
            title: "Contact",
            press: () {},
          ),
          MenuItem(
            title: "Login",
            press: () {},
          ),
          DefaultButton(
            text: "Get Started",
            press: () {},
          ),
        ],
      ),
    );
  }
}
