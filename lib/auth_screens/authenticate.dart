// root authentication widget

import "package:flutter/material.dart";
import 'package:fundder/services/auth.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/helper_classes.dart';
//import 'package:fundder/auth_screens/register.dart';
//import 'package:fundder/auth_screens/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate>
    with SingleTickerProviderStateMixin {
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

  int _currentIndex = 0;

  TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      //index = _tabController.index;
      //colorChanged = false;
      setState(() {});
    }
    print(_tabController.animation.value);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            //resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.white,
            appBar: null,
            body: ListView(children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 40),
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    child: Image.asset('assets/images/fundder_loading.png'),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [Tab(text: 'Sign In'), Tab(text: 'Register')],
                      controller: _tabController,
                    ),
                    [_signIn(), _register()][_tabController.index]
                  ],
                ),
              )
            ]),
          );
  }

  Widget _signIn() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 30.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Email'),
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                GestureDetector(
                  child: Container(
                    width: 250,
                    padding: EdgeInsets.symmetric(
                      vertical: 12, /*horizontal: 30*/
                    ),
                    margin: EdgeInsets.only(left: 50, right: 50, bottom: 10),
                    decoration: BoxDecoration(
                      color: HexColor('ff6b6c'),
                      border: Border.all(color: HexColor('ff6b6c'), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      "Sign In",
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
                      dynamic result = await _auth.signInWithEmailAndPassword(
                          email, password);
                      if (result == null) {
                        setState(() {
                          error = 'Failed to sign in user';
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
            ))
        //)
        //),
        );
  }

  Widget _register() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 50.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  decoration:
                      textInputDecoration.copyWith(hintText: 'Username'),
                  validator: (val) => val.isEmpty ? 'Enter a username' : null,
                  onChanged: (val) {
                    setState(() {
                      username = val;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Email'),
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
                      val == password ? null : 'Passwords do not match',
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
                    margin: EdgeInsets.only(left: 50, right: 50, bottom: 10),
                    decoration: BoxDecoration(
                      color: HexColor('ff6b6c'),
                      border: Border.all(color: HexColor('ff6b6c'), width: 1),
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
