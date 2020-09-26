import 'package:flutter/material.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/global_widgets/auth_button.dart';
import 'package:fundder/helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'terms_of_use.dart';
import 'dart:io' show Platform;
import 'package:fundder/global_widgets/dialogs.dart';

class AuthenticationHome extends StatelessWidget {
  final Function emailChosenMethod;
  final Function(bool) isLoadingChanged;
  final Function(String) hasError;
  AuthenticationHome(
      {this.emailChosenMethod, this.isLoadingChanged, this.hasError});
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Column(children: [
              Expanded(
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Image.asset(
                                  'assets/images/pink_bear_with_text.png')),
                          SizedBox(height: 20),
                          Text(
                            'Get hooked on giving',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ))),
              AuthFundderButton(
                onPressed: () async {
                  this.isLoadingChanged(true);
                  String status = await _auth.loginWithFacebook(context);
                  if (status == "Email account exists") {
                    this.hasError("Email account exists");
                  }
                  this.isLoadingChanged(false);
                },
                backgroundColor: HexColor('4267B2'),
                borderColor: HexColor('4267B2'),
                textColor: Colors.white,
                text: 'Continue with Facebook',
                buttonIconData: FontAwesome5Brands.facebook_f,
                iconColor: Colors.white,
              ),
              AuthFundderButton(
                onPressed: () async {
                  this.isLoadingChanged(true);
                  await _auth.signInWithGoogle();
                  this.isLoadingChanged(false);
                },
                backgroundColor: HexColor('4285F4'),
                textColor: Colors.white,
                borderColor: HexColor('4285F4'),
                text: 'Continue with Google',
                buttonIconData: FontAwesome5Brands.google,
                iconColor: Colors.white,
              ),
              Platform.isIOS
                  ? AuthFundderButton(
                      onPressed: () async {
                        this.isLoadingChanged(true);
                        await _auth.loginWithApple();
                        this.isLoadingChanged(false);
                      },
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      borderColor: Colors.black,
                      text: 'Continue with Apple',
                      buttonIconData: FontAwesome5Brands.apple,
                      iconColor: Colors.white,
                    )
                  : Container(height: 0),
              AuthFundderButton(
                onPressed: emailChosenMethod,
                backgroundColor: HexColor('ff6b6c'),
                textColor: Colors.white,
                borderColor: HexColor('ff6b6c'),
                text: 'Continue with Email',
                buttonIconData: FontAwesome.envelope,
                iconColor: Colors.white,
              ),
              SizedBox(height: 25.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TermsView()));
                },
                child: Text(
                  'Terms of use',
                  style: TextStyle(
                      color: HexColor('ff6b6c'), fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 25.0),
            ])));
  }
}
