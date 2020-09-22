import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/auth_screens/terms_of_use.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/shared/loading.dart';

class EmailRegistration extends StatefulWidget {
  final AuthService auth = AuthService();
  @override
  _EmailRegistrationState createState() => _EmailRegistrationState();
}

class _EmailRegistrationState extends State<EmailRegistration> {
  String email = '';
  String password = '';
  final _registerKey = GlobalKey<FormState>();
  String registrationerror = '';
  bool loading = false;
  bool passwordsMatch = false;
  bool termsAccepted = true;
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
                                  child: Container()))
                        ],
                      )),
                  Expanded(
                    child: Center(
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        child: Text('Register with email',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 30)),
                      ),
                    ),
                  ),
                  Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 50.0),
                      child: Form(
                        key: _registerKey,
                        child: Column(children: <Widget>[
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp("[ ]"))
                            ],
                            initialValue: email,
                            decoration:
                                textInputDecoration.copyWith(hintText: 'Email'),
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
                              FilteringTextInputFormatter.deny(RegExp("[ ]"))
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
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp("[ ]"))
                            ],
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Confirm password'),
                            validator: (val) => val == password
                                ? null
                                : 'Passwords do not match',
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TermsView()));
                            },
                            child: Text(
                              'Terms of use',
                              style: TextStyle(color: HexColor('ff6b6c')),
                            ),
                          ),
                          StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
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
                          dynamic result = await widget.auth
                              .registerWithEmailPassword(
                                  email.trimRight(), password);
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
                                registrationerror =
                                    'Please accept our terms of use';
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
              ),
            )
          ]);
  }
}
