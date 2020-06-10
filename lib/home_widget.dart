import 'package:flutter/material.dart';
import 'package:fundder/feed_controller.dart';
import 'placeholder_widget.dart';
import 'feed_controller.dart';
import 'search_controller.dart';
import 'liked_controller.dart';
import 'profile_controller.dart';
import 'add_post_controller.dart';
import 'helper_classes.dart';

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
   ProfileController()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),// new : in the body, load the child widget depending on the current index, which is determined by which button is clicked in the bottomNavBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: HexColor("A3D165"), //hexcolor method is custom at bottom
        iconSize: 30,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.format_align_right),
            title: Text('Home'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Messages'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            title: Text('Profile'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            title: Text('Profile'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Profile')
          )
        ],
      ),
    );
  }
  
  void onTabTapped(int index) {
    if(index!=2){setState(() {
     _currentIndex = index;
     });
    } else {
      Navigator.of(context).push(_createRoute());
    }
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => Page2(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}
