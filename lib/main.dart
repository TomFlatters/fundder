import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //Crashlytics.instance.enableInDevMode = false;
  //await Firestore.instance.settings(host: '10.0.2.2:8080', sslEnabled: false);
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
                  debugShowCheckedModeBanner: false,
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
                              fontFamily: 'Founders Grotesk')),
                      textTheme: TextTheme(
                          bodyText2: TextStyle(
                              //fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'Founders Grotesk')),
                      tabBarTheme: TabBarTheme(
                          labelStyle: TextStyle(
                              fontFamily: 'Founders Grotesk',
                              fontWeight: FontWeight.bold),
                          unselectedLabelStyle:
                              TextStyle(fontFamily: 'Founders Grotesk'),
                          indicator: UnderlineTabIndicator(
                              borderSide:
                                  BorderSide(width: 2.0, color: Colors.grey))),
                      fontFamily: 'Founders Grotesk',
                      appBarTheme: AppBarTheme(elevation: 0)));
            }));
  }
}
