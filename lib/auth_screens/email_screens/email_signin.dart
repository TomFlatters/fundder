import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/auth_screens/terms_of_use.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/global_widgets/dialogs.dart';

class EmailSignIn extends StatefulWidget {
  final AuthService auth = AuthService();
  @override
  _EmailSignInState createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  String email = '';
  String password = '';
  final _signinKey = GlobalKey<FormState>();
  String signinerror = '';
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : ListView(children: [
            Container(
              height: MediaQuery.of(context).size.height - 30,
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 40,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {},
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.centerRight,
                            child: FlatButton(
                                onPressed: () {}, child: Text('Register')),
                          ))
                        ],
                      )),
                  Expanded(
                    child: Center(
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        child: Text('Log in with email',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 30)),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      child: Form(
                          key: _signinKey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp("[ ]"))
                                  ],
                                  initialValue: email,
                                  decoration: textInputDecoration.copyWith(
                                      hintText: 'Email'),
                                  validator: (val) =>
                                      val.isEmpty ? 'Enter an email' : null,
                                  onChanged: (val) {
                                    if (mounted)
                                      setState(() {
                                        email = val;
                                      });
                                  },
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp("[ ]"))
                                  ],
                                  decoration: textInputDecoration.copyWith(
                                      hintText: 'Password'),
                                  validator: (val) => val.length < 6
                                      ? 'Enter a password longer than 5 characters'
                                      : null,
                                  obscureText: true,
                                  onChanged: (val) {
                                    if (mounted)
                                      setState(() {
                                        password = val;
                                      });
                                  },
                                ),
                                SizedBox(height: 20.0),
                                GestureDetector(
                                  onTap: () async {
                                    if (email != '') {
                                      signinerror = await widget.auth
                                          .forgotPassword(email);
                                      DialogManager().createDialog(
                                          'Error', signinerror, context);
                                      if (mounted) setState(() {});
                                    } else {
                                      if (mounted)
                                        setState(() {
                                          signinerror =
                                              'Please enter your email for us to send a reset link';
                                        });
                                      DialogManager().createDialog(
                                          'Error', signinerror, context);
                                    }
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                        color: HexColor('ff6b6c'),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                )
                              ]))),
                  PrimaryFundderButton(
                    text: 'Log In',
                    onPressed: () async {
                      if (_signinKey.currentState.validate()) {
                        if (mounted) setState(() => loading = true);
                        String result = await widget.auth
                            .signInWithEmailAndPassword(email, password);
                        if (result == null) {
                          if (mounted)
                            setState(() {
                              signinerror = 'Failed to sign in user';
                              loading = false;
                            });
                          DialogManager()
                              .createDialog('Error', signinerror, context);
                        } else {
                          if (mounted) {
                            if (mounted)
                              setState(() {
                                signinerror = result;
                                loading = false;
                              });
                            DialogManager()
                                .createDialog('Error', signinerror, context);
                          }
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20.0),
                  GestureDetector(
                      onTap: () {},
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            Text(
                              "Register",
                              style: TextStyle(
                                  color: HexColor('ff6b6c'),
                                  fontWeight: FontWeight.w600),
                            )
                          ])),
                  SizedBox(height: 25.0),
                ],
              ),
            )
          ]);
  }
}
