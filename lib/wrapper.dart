import 'package:flutter/material.dart';
import 'package:fundder/auth_screens/authenticate.dart';
import 'package:fundder/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    // context passes down the user data, this is how we get it:
    final user = Provider.of<User>(context);

    // return either Home or Authenticate widget (depending on auth status)
    return (user!=null) ? Home() : Authenticate();

  }
}