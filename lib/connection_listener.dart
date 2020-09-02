import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'helper_classes.dart';

class ConnectionListener extends StatefulWidget {
  @override
  _ConnectionListenerState createState() => _ConnectionListenerState();
}

class _ConnectionListenerState extends State<ConnectionListener> {
  var subscription;
  var connectionStatus;

  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (mounted) {
        setState(() => connectionStatus = result);
      }
    });
    print('connection status' + connectionStatus.toString());
    connectionStatus = Connectivity()
        .checkConnectivity()
        .then((value) => setState(() => connectionStatus = value));
    super.initState();
  }

  Widget checkInternetConnectivity() {
    if (connectionStatus == ConnectivityResult.none) {
      return Container(
        color: HexColor('ff6b6c'),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
            child: Text(
          "Check your internet connection",
          style: TextStyle(color: Colors.white),
        )),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return checkInternetConnectivity();
  }
}
