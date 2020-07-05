import 'package:flutter/material.dart';
import 'package:fundder/auth_screens/authenticate.dart';
import 'package:fundder/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/feed_web.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // context passes down the user data, this is how we get it:
    final user = Provider.of<User>(context);

    if (kIsWeb == true) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/about'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
      // return either Home or Authenticate widget (depending on auth status)
      return (user != null) ? Home() : Authenticate();
    }

    // if you comment out the above line and uncomment the below line you won't need to login to see the home widget
    // return Home();
  }
}
