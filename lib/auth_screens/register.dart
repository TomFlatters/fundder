import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  // key associated with form. Tracks state of form
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String password = '';

  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('Register for Fundder')
        ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: 
            Column(children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                validator: (val) => val.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                validator: (val) => val.length<6 ? 'Enter a password longer than 5 characters' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // the form is valid when ALL the form key validations return null
                  FlatButton(
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        if(_formKey.currentState.validate()){
                          dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                          if (result==null){
                            setState(() {
                              error = 'Failed to sign in user';
                            });
                          }
                        }
                      }
                    },
                    child: Text('Sign in')),
                  SizedBox(width: 30.0),
                  FlatButton(
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                        if (result==null){
                          setState(() {
                            error = 'An error occurred';
                          });
                        }
                      }
                    },
                    child: Text('Register')),
                    
                  ]
                ),
              SizedBox(height: 12.0),
              Text(
                error,
                )
            ],
          )
        )
        )
      );
  }
}