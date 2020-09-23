import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fundder/services/auth.dart';
import 'email_screens/email_registration.dart';
import 'email_screens/email_signin.dart';
import 'authentication_home.dart';

class AuthenticationController extends StatefulWidget {
  @override
  _AuthenticationControllerState createState() =>
      _AuthenticationControllerState();
}

class _AuthenticationControllerState extends State<AuthenticationController> {
  CarouselController _carouselController = CarouselController();
  int _current = 0;
  bool _email = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              _changePage();
              if (mounted) {
                setState(() {
                  _current = index;
                });
              }
            },
            enableInfiniteScroll: false,
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            // autoPlay: false,
          ),
          items: _email == false
              ? [
                  AuthenticationHome(
                    emailChosenMethod: _emailChosen,
                  )
                ]
              : [
                  AuthenticationHome(
                    emailChosenMethod: _emailChosen,
                  ),
                  EmailSignIn(
                    nextPage: _carouselController.nextPage,
                    previousPage: _carouselController.previousPage,
                  ),
                  EmailRegistration(
                    previousPage: _carouselController.previousPage,
                  )
                ]),
    );
  }

  void _changePage() {
    // Set state to make sure that views instantiate with the latest values
    setState(() {});
    FocusScope.of(context).unfocus();
  }

  void _emailChosen() {
    setState(() {
      _email = true;
    });
    _carouselController.nextPage();
  }
}
