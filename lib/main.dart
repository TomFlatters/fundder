import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'home_widget.dart';
import 'helper_classes.dart';
import 'routes/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';

void main() {
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  FluroRouter.setupRouter();
  runZoned(() {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
FirebaseAnalytics analytics = FirebaseAnalytics();
FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
        // listen to the stream specified by value
        value: AuthService().user,
        child: StreamBuilder<User>(
            stream: AuthService().user,
            builder: (context, snapshot) {
              return MaterialApp(
                  initialRoute: '/',
                  onGenerateRoute: FluroRouter.router.generator,
                  title: 'Fundder',
                  navigatorObservers: [
                    routeObserver,
                    observer,
                  ],
                  home: snapshot.connectionState != ConnectionState.waiting
                      ? Wrapper()
                      : Loading(),
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
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold),
                          unselectedLabelStyle:
                              TextStyle(fontFamily: 'Quicksand'),
                          indicator: UnderlineTabIndicator(
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.grey))),
                      fontFamily: 'Muli',
                      appBarTheme: AppBarTheme(elevation: 0)));
            }));
  }
}
