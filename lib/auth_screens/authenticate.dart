// root authentication widget

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'terms_of_use.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  // key associated with form. Tracks state of form
  final _signinKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  // is the screen loading? show loading widget if so
  bool loading = false;
  bool passwordsMatch = false;

  // text field state
  String email = '';
  String password = '';
  String username = '';

  String signinerror = '';
  String registrationerror = '';

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
      if (mounted) {
        setState(() {});
      }
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
                    child: Image.asset('assets/images/pink_bear.png'),
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
    return Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
                key: _signinKey,
                child: Column(children: <Widget>[
                  PrimaryFundderButton(
                    onPressed: () {
                      _auth.signInWithGoogle();
                    },
                    text: 'Sign in with Google',
                  ),
                  SizedBox(height: 30.0),
                  PrimaryFundderButton(
                    onPressed: () {
                      _auth.loginWithFacebook(context);
                    },
                    text: 'Sign in with Facebook',
                  ),
                  SizedBox(height: 30.0),
                  PrimaryFundderButton(
                    onPressed: () {
                      _auth.loginWithApple();
                    },
                    text: 'Sign in with Apple',
                  ),
                  SizedBox(height: 30.0),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp("[ ]"))
                    ],
                    initialValue: email,
                    decoration: textInputDecoration.copyWith(hintText: 'Email'),
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
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
                      FilteringTextInputFormatter.deny(RegExp("[ ]"))
                    ],
                    decoration:
                        textInputDecoration.copyWith(hintText: 'Password'),
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  )
                ]))),
        PrimaryFundderButton(
          text: 'Log In',
          onPressed: () async {
            if (_signinKey.currentState.validate()) {
              if (mounted) setState(() => loading = true);
              String result =
                  await _auth.signInWithEmailAndPassword(email, password);
              if (result == null) {
                if (mounted)
                  setState(() {
                    signinerror = 'Failed to sign in user';
                    loading = false;
                  });
              } else {
                if (mounted) {
                  if (mounted)
                    setState(() {
                      signinerror = result;
                      loading = false;
                    });
                }
              }
            }
          },
        ),
        //SizedBox(height: 6.0),
        EditFundderButton(
            text: 'Forgot Password',
            onPressed: () async {
              if (email != '') {
                signinerror = await _auth.forgotPassword(email);
                if (mounted) setState(() {});
              } else {
                if (mounted)
                  setState(() {
                    signinerror =
                        'Please enter your email for us to send a reset link';
                  });
              }
            }),
        SizedBox(height: 6.0),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => TermsView()));
          },
          child: Text(
            'Terms of use',
            style: TextStyle(color: HexColor('ff6b6c')),
          ),
        ),
        SizedBox(height: 6.0),
        Text(
          signinerror,
          textAlign: TextAlign.center,
        )
      ],
    );
    //)
    //),
  }

  Widget _register() {
    bool termsAccepted = false;
    return Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 50.0),
            child: Form(
              key: _registerKey,
              child: Column(children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp("[ ]")),
                  ],
                  initialValue: username,
                  decoration:
                      textInputDecoration.copyWith(hintText: 'Username'),
                  validator: (val) => val.isEmpty ? 'Enter a username' : null,
                  onChanged: (val) {
                    if (mounted)
                      setState(() {
                        username = val;
                      });
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp("[ ]"))
                  ],
                  initialValue: email,
                  decoration: textInputDecoration.copyWith(hintText: 'Email'),
                  validator: (val) => val.isEmpty ? 'Enter an email' : null,
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
                    FilteringTextInputFormatter.deny(RegExp("[ ]"))
                  ],
                  decoration:
                      textInputDecoration.copyWith(hintText: 'Password'),
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
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp("[ ]"))
                  ],
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
                SizedBox(height: 30.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TermsView()));
                  },
                  child: Text(
                    'Terms of use',
                    style: TextStyle(color: HexColor('ff6b6c')),
                  ),
                ),
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return CheckboxListTile(
                    activeColor: Colors.grey,
                    title: Text("I accept the Fundder terms of use",
                        style: TextStyle(fontSize: 13)),
                    value: termsAccepted,
                    onChanged: (newValue) {
                      if (mounted)
                        setState(() {
                          termsAccepted = newValue;
                        });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, //  <-- leading Checkbox
                  );
                }),
              ]),
            )),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        PrimaryFundderButton(
          text: 'Register',
          onPressed: () async {
            if (_registerKey.currentState.validate()) {
              if (termsAccepted == true) {
                if (mounted) setState(() => loading = true);
                dynamic result = await _auth.registerWithEmailPasswordUsername(
                    email.trimRight(), password, username.trimRight());
                if (result == null) {
                  if (mounted)
                    setState(() {
                      registrationerror = 'An error occurred';
                      loading = false;
                    });
                } else {
                  if (mounted) {
                    if (mounted)
                      setState(() {
                        registrationerror = result;
                        loading = false;
                      });
                  }
                }
              } else {
                if (mounted) {
                  if (mounted)
                    setState(() {
                      registrationerror = 'Please accept our terms of use';
                      loading = false;
                    });
                }
              }
            }
          },
        ),
        SizedBox(height: 6.0),
        SizedBox(height: 6.0),
        Text(
          registrationerror,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
