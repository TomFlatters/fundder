import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'home_widget.dart';
import 'helper_classes.dart';
import 'routes/routes.dart';

void main() {
  FluroRouter.setupRouter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      // listen to the stream specified by value
      value: AuthService().user,
      child: MaterialApp(
          initialRoute: '/',
          onGenerateRoute: FluroRouter.router.generator,
          title: 'My Flutter App',
          home: Wrapper(),
          theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              primaryColor: Colors.white,
              accentColor: HexColor('b8b8d1'),
              primaryTextTheme: TextTheme(
                  headline6: TextStyle(
                      //fontWeight: FontWeight.w600,
                      fontSize: 20,
                      fontFamily: 'Roboto Mono')),
              tabBarTheme: TabBarTheme(
                  labelStyle: TextStyle(
                      fontFamily: 'Quicksand', fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontFamily: 'Quicksand'),
                  indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2.0, color: Colors.grey))),
              fontFamily: 'Muli',
              appBarTheme: AppBarTheme(elevation: 0))),
    );
  }
}
