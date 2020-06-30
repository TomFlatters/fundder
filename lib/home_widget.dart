import 'package:flutter/material.dart';
import 'package:fundder/feed_controller.dart';
import 'placeholder_widget.dart';
import 'feed_controller.dart';
import 'search_controller.dart';
import 'liked_controller.dart';
import 'profile_controller.dart';
import 'add_post_controller.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> screens = [
    FeedController(Colors.white),
    SearchController(),
    PlaceholderWidget(Colors.deepOrange),
    LikedController(),
    ProfileController()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ), // new : in the body, load the child widget depending on the current index, which is determined by which button is clicked in the bottomNavBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor:
            Color.fromRGBO(0, 0, 0, 0.5), //hexcolor method is custom at bottom
        iconSize: 26,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.home,
            ),
            title: showIndicator(_currentIndex == 0),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.search1,
            ),
            title: showIndicator(_currentIndex == 1),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.plussquareo,
            ),
            title: showIndicator(_currentIndex == 2),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.hearto,
            ),
            title: showIndicator(_currentIndex == 3),
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              AntDesign.user,
            ),
            title: showIndicator(_currentIndex == 4),
          )
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
    if (index != 2) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      Navigator.pushNamed(context, '/addpost');
    }
  }
}
