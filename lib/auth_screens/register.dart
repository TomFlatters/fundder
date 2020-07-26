import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/helper_classes.dart';
import 'sign_in.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  // key associated with form. Tracks state of form
  final _formKey = GlobalKey<FormState>();

  // is the screen loading? show loading widget if so
  bool loading = false;
  bool passwordsMatch = false;

  // text field state
  String email = '';
  String password = '';
  String username = '';

  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Username'),
                      validator: (val) =>
                          val.isEmpty ? 'Enter a username' : null,
                      onChanged: (val) {
                        setState(() {
                          username = val;
                        });
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Email'),
                      validator: (val) => val.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Password'),
                      validator: (val) => val.length < 6
                          ? 'Enter a password longer than 5 characters'
                          : null,
                      obscureText: true,
                      onChanged: (val) {
                        setState(() {
                          password = val;
                        });
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Confirm password'),
                      validator: (val) =>
                          val == password ? 'Passwords do not match' : null,
                      obscureText: true,
                      onChanged: (val) {
                        if (val == password) {
                          passwordsMatch = true;
                        } else {
                          passwordsMatch = false;
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 250,
                        padding: EdgeInsets.symmetric(
                          vertical: 12, /*horizontal: 30*/
                        ),
                        margin:
                            EdgeInsets.only(left: 50, right: 50, bottom: 10),
                        decoration: BoxDecoration(
                          color: HexColor('ff6b6c'),
                          border:
                              Border.all(color: HexColor('ff6b6c'), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Text(
                          "Register",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          dynamic result =
                              await _auth.registerWithEmailPasswordUsername(
                                  email, password, username);
                          if (result == null) {
                            setState(() {
                              error = 'An error occurred';
                              loading = false;
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                    )
                  ],
                )));
  }
}
