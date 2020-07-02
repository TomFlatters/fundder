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
    Widget _isOnWeb() {
      if (kIsWeb) {
        return WebFeed();
      } else {
        return Home();
      }
    }

    // context passes down the user data, this is how we get it:
    final user = Provider.of<User>(context);

    // return either Home or Authenticate widget (depending on auth status)
    return (user != null) ? _isOnWeb() : Authenticate();

    // if you comment out the above line and uncomment the below line you won't need to login to see the home widget
    // return Home();
  }
}
