import 'package:flutter/material.dart';
import 'package:fundder/feed_controller.dart';
import 'placeholder_widget.dart';
import 'feed_controller.dart';
import 'search_controller.dart';
import 'liked_controller.dart';
import 'profile_controller.dart';

class Home extends StatefulWidget {
 @override
 State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
   FeedController(Colors.white),
   SearchController(),
   PlaceholderWidget(Colors.deepOrange),
   LikedController(),
   ProfileController()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex], // new
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
            icon: Icon(Icons.favorite_border),
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
    transitionDuration: Duration(milliseconds: 100),
  );
}

class Page2 extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Page 2'),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

