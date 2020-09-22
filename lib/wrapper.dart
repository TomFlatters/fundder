import 'package:flutter/material.dart';
//import 'package:fundder/auth_screens/authenticate.dart';
import 'auth_screens/authentication_controller.dart';
import 'package:fundder/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class Wrapper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WrapperState();
  }
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
  }

  void initDynamicLinks() async {
    print('init dynamic links');
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleLinkData(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData dynamicLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (dynamicLink != null) {
      if (dynamicLink != null) {
        Navigator.pushNamed(context, dynamicLink.link.path);
      }
      //handleLinkData(dynamicLink);
    }
  }

  void handleLinkData(PendingDynamicLinkData data) {
    final Uri uri = data?.link;
    print("uri: " + uri.toString());
    if (uri != null) {
      Navigator.pushNamed(context, uri.path);
    }
    /*final queryParams = uri.queryParameters;
      if (queryParams.length > 0 && queryParams['post'] != null) {
        String post = queryParams["post"];
        print("pushing " + post);
        Navigator.pushNamed(context, "/post/" + post);
        // verify the username is parsed correctly

      }
    }*/
  }

  @override
  Widget build(BuildContext context) {
    // context passes down the user data, this is how we get it:
    final user = Provider.of<User>(context);

    // return either Home or Authenticate widget (depending on auth status)
    return (user != null) ? Home() : AuthenticationController();

    // if you comment out the above line and uncomment the below line you won't need to login to see the home widget
    // return Home();
  }
}
