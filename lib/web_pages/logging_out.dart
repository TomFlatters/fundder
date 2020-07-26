import 'package:flutter/material.dart';
import 'menu_item.dart';
import 'default_button.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/models/user.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/auth.dart';

class LoggingOut extends StatefulWidget {
  @override
  _LoggingOutState createState() => _LoggingOutState();
}

class _LoggingOutState extends State<LoggingOut> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, '/web/login');
      });
    }
    return Text('Logging Out...');
  }
}
