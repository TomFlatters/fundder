import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      // listen to the stream specified by value
      value: AuthService().user,
      child: MaterialApp(
        title: 'My Flutter App',
        home: Wrapper(),
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          primaryColor: Colors.white,
          primaryTextTheme: TextTheme(
            headline6: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            )
          ),
          tabBarTheme: TabBarTheme(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: HexColor("A3D165")) 
              )
          ),
          fontFamily: 'Muli',
          appBarTheme: AppBarTheme(
            elevation: 0
          )
        )
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
