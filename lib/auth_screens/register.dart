import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/helper_classes.dart';

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
        title: null,
          /*Padding(
            child: Text('Fundder', 
              style: new TextStyle(
                fontSize: 30.0,
              ),
            ), 
            padding: EdgeInsets.only(top: 20.0),
          ),
        centerTitle: true,*/
        ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: 
            Column(children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(vertical: 40),
                  color: Colors.white,
                  child: Center(
                    child: Container(
                        // Use the properties stored in the State class.
                        width: 150,
                        height: 150,
                        child: Image.asset('assets/images/fundder_loading.png'),
                        // Define how long the animation should take.
                        // Provide an optional curve to make the animation feel smoother.
                      ),/*SpinKitChasingDots(
                            color: Color(0xffA3D165),
                            size: 50.0,
                        ),*/
                  ),
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
                /*Row(
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
                  SizedBox(width: 30.0),*/
                  /*FlatButton(
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
                    
                  ]*/
                //),
                Padding(padding: EdgeInsets.symmetric(vertical:15),),
                GestureDetector(
                  child: Container(
                    width: 250,
                    padding: EdgeInsets.symmetric(vertical: 12, /*horizontal: 30*/),
                    margin: EdgeInsets.only(left: 50, right:50, bottom: 10),
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
                ),
                GestureDetector(
                  child: Container(
                    width: 250,
                    padding: EdgeInsets.symmetric(vertical: 12, /*horizontal: 30*/),
                    margin: EdgeInsets.only(left: 50, right:50, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: HexColor('ff6b6c'), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      "Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: HexColor('ff6b6c'),
                        ),
                      ),
                    ),
                  onTap: () async {
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