import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'dart:async';

class CheckVerified extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<CheckVerified>
    with SingleTickerProviderStateMixin {
  // create auth service instance available for use here
  final AuthService _auth = AuthService();
  // key associated with form. Tracks state of form
  final _formKey = GlobalKey<FormState>();

  // is the screen loading? show loading widget if so
  bool loading = false;
  bool verified = true;

  // text field state
  String email = '';
  String password = '';

  String error = '';
  String verificationText = '';

  bool _isUserEmailVerified = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    // ... any code here ...
    Future(() async {
      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        await FirebaseAuth.instance.currentUser()
          ..reload();
        var user = await FirebaseAuth.instance.currentUser();
        if (user.isEmailVerified) {
          setState(() {
            _isUserEmailVerified = user.isEmailVerified;
          });
          Navigator.pop(context, true);
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return loading == true
        ? Loading()
        : WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text('Verification'),
                  actions: <Widget>[],
                  leading: new Container(),
                ),
                body: Container(
                    child: Column(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text('Congratulations! Your account is created.'),
                          Text('Please verify your email to access the app.'),
                          SizedBox(
                            height: 30,
                          ),
                          Text('Verification email has been sent to:'),
                          SizedBox(
                            height: 5,
                          ),
                          Text(user != null ? user.email : "user email",
                              style: TextStyle(
                                  fontFamily: "Founders Grotesk",
                                  fontSize: 17)),
                        ])),
                    Expanded(
                      child: Container(),
                    ),
                    PrimaryFundderButton(
                      text: 'I have verified',
                      onPressed: () async {
                        FirebaseUser user =
                            await FirebaseAuth.instance.currentUser();
                        await user.reload();
                        user = await FirebaseAuth.instance.currentUser();
                        if (user.isEmailVerified == true) {
                          Navigator.pop(context);
                          /*Navigator.pushReplacementNamed(
                                  context, '/' + user.uid + '/addProfilePic');*/
                          /*Navigator.pushNamed(
                                  context, '/' + user.uid + '/tutorial');*/
                        } else {
                          if (mounted)
                            setState(() {
                              verificationText = 'Email is not yet verified';
                            });
                          DialogManager()
                              .createDialog('Error', verificationText, context);
                        }
                      },
                    ),
                    SecondaryFundderButton(
                        text: 'Send email again',
                        onPressed: () async {
                          FirebaseUser user =
                              await FirebaseAuth.instance.currentUser();
                          user.sendEmailVerification();
                          if (mounted)
                            setState(() {
                              verificationText = 'Verification email sent';
                            });
                          DialogManager().createDialog(
                              'Email sent', verificationText, context);
                        }),
                    SecondaryFundderButton(
                      text: 'Sign out',
                      onPressed: () async {
                        if (mounted)
                          setState(() {
                            loading = true;
                          });
                        await _auth.signOut();
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ))));
  }
}
