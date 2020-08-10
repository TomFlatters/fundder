import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';

class CheckVerified extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<CheckVerified> {
  // create auth service instance available for use here
  final AuthService _auth = AuthService();
  // key associated with form. Tracks state of form
  final _formKey = GlobalKey<FormState>();

  // is the screen loading? show loading widget if so
  bool loading = false;

  // text field state
  String email = '';
  String password = '';

  String error = '';
  String verificationText = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Verification'),
              actions: <Widget>[],
              leading: new Container(),
            ),
            body: Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: <Widget>[
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
                        style:
                            TextStyle(fontFamily: "Roboto Mono", fontSize: 17)),
                    Expanded(
                      child: Container(),
                    ),
                    Text(verificationText),
                    PrimaryFundderButton(
                      text: 'I have verified',
                      onPressed: () async {
                        FirebaseUser user =
                            await FirebaseAuth.instance.currentUser();
                        await user.reload();
                        user = await FirebaseAuth.instance.currentUser();
                        if (user.isEmailVerified == true) {
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            verificationText = 'Email not verified';
                          });
                        }
                      },
                    ),
                    SecondaryFundderButton(
                        text: 'Send email again',
                        onPressed: () async {
                          FirebaseUser user =
                              await FirebaseAuth.instance.currentUser();
                          user.sendEmailVerification();
                          setState(() {
                            verificationText = 'Verification email sent';
                          });
                        }),
                    SecondaryFundderButton(
                      text: 'Sign out',
                      onPressed: () async {
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
