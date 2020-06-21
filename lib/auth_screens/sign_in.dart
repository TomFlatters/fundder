import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/shared/constants.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/helper_classes.dart';
import 'register.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

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

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: 
            Column(children: <Widget>[
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
              SizedBox(height: 12.0),
              Text(
                error,
                )
            ],
          )
        )
        //)
      //),
      );
  }
}

Route _goToRegister() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Register(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}