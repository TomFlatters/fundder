import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/shared/loading.dart';

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

  // text field state
  String email = '';
  String password = '';

  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: 
          Padding(
            child: Text('Fundder', 
              style: new TextStyle(
                fontSize: 30.0,
              ),
            ), 
            padding: EdgeInsets.only(top: 20.0),
          ),
        centerTitle: true,
        ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: 
            Column(children: <Widget>[
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
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
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
                    color:  Color(0xffA3D165),
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(8.0),
                    splashColor: Color(0xffA3D165),
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        setState(() => loading = true);
                        dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                        if (result==null){
                          setState(() {
                            error = 'Failed to sign in user';
                            loading = false;
                          });
                        }
                      }
                    },

                    child: Text('Sign in')),
                  SizedBox(width: 30.0),
                  FlatButton(
                    color:  Color(0xffA3D165),
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(8.0),
                    splashColor: Color(0xffA3D165),
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        setState(() => loading = true);
                        dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                        if (result==null){
                          setState(() {
                            error = 'An error occurred';
                            loading = false;
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