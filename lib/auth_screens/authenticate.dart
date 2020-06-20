// root authentication widget

import "package:flutter/material.dart";
import 'package:fundder/auth_screens/register.dart';
import 'package:fundder/auth_screens/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  int _currentIndex = 0;
  final List<Widget> screens = [
   SignIn(),
   Register()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),// new : in the body, load the child widget depending on the current index, which is determined by which button is clicked in the bottomNavBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromRGBO(0, 0, 0, 0.5), //hexcolor method is custom at bottom
        iconSize: 26,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Text('Sign In'),
            title: Text('Sign In'),
          ),
          new BottomNavigationBarItem(
            icon: Text('Register'),
            title: Text('Register'),
          ),
        ],
      ),
    );
  }

  Widget showIndicator(bool show) {
  return show
      ? Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 0),
          child: Icon(Icons.brightness_1, size: 4, color: Colors.black),
        )
      : SizedBox(height: 8);
  }
  
  void onTabTapped(int index) {
    if(index!=2){setState(() {
     _currentIndex = index;
     });
  }
}
}