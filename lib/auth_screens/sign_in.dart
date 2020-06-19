import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  // create auth service instance available for use here
  final AuthService _auth = AuthService();

  // text field state
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in to Fundder')
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
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
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                onPressed: () async {
                  print(email);
                  print(password);
                },
                child: Text('Sign In'))
            ],
          )
        )
        )
      );
  }
}