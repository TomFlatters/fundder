import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Verification'),
          actions: <Widget>[],
          leading: new Container(),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text('Congratulations! Your account is created.'),
            Text('Please verify your email to access the app.'),
            Expanded(
              child: Container(),
            ),
            Text(verificationText),
            PrimaryFundderButton(
              text: 'I have verified',
              onPressed: () async {
                FirebaseUser user = await FirebaseAuth.instance.currentUser();
                await user.reload();
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
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  user.sendEmailVerification();
                  setState(() {
                    verificationText = 'Verification email sent';
                  });
                }),
            SizedBox(
              height: 30,
            )
          ],
        ));
  }
}
