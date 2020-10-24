import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fundder/services/auth.dart';
import 'email_screens/email_registration.dart';
import 'email_screens/email_signin.dart';
import 'authentication_home.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/global_widgets/dialogs.dart';

class AuthenticationController extends StatefulWidget {
  @override
  _AuthenticationControllerState createState() =>
      _AuthenticationControllerState();
}

class _AuthenticationControllerState extends State<AuthenticationController> {
  CarouselController _carouselController = CarouselController();
  int _current = 0;
  bool _email = false;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading == true
        ? Loading()
        : Scaffold(
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
                            isLoadingChanged: _loadingChanged,
                            hasError: _showError)
                      ]
                    : [
                        AuthenticationHome(
                            emailChosenMethod: _emailChosen,
                            isLoadingChanged: _loadingChanged,
                            hasError: _showError),
                        EmailSignIn(
                          nextPage: _carouselController.nextPage,
                          previousPage: _carouselController.previousPage,
                          isLoadingChanged: _loadingChanged,
                        ),
                        EmailRegistration(
                          previousPage: _carouselController.previousPage,
                          isLoadingChanged: _loadingChanged,
                        )
                      ]),
          );
  }

  void _changePage() {
    // Set state to make sure that views instantiate with the latest values
    setState(() {});
    FocusScope.of(context).unfocus();
  }

  void _loadingChanged(bool newLoadingStatus) {
    if (mounted) {
      setState(() {
        _isLoading = newLoadingStatus;
      });
    }
  }

  void _emailChosen() {
    setState(() {
      _email = true;
    });
    _carouselController.nextPage();
  }

  void _showError(String error) {
    DialogManager().createDialog(
        "Cannot log in",
        "You already have an email-based account. Therefore you can only log in through email or google. You can link this account with Facebook in your profile menu.",
        context);
  }
}
