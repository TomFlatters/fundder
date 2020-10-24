import 'package:flutter/material.dart';
import 'package:fundder/shared/loading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/auth_button.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/helper_classes.dart';

class LinkFacebook extends StatefulWidget {
  final Function loggedIn;
  LinkFacebook({this.loggedIn});
  @override
  _LinkFacebookState createState() => _LinkFacebookState();
}

class _LinkFacebookState extends State<LinkFacebook> {
  final _auth = AuthService();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Center(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Find your Facebook friends on Fundder.',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 30)),
                      SizedBox(height: 25),
                      AuthFundderButton(
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          String result = await _auth.linkAccountToFacebook();
                          print(result);

                          setState(() {
                            loading = false;
                          });
                          DialogManager().createDialog(
                              "Link to Facebook", result, context);
                          widget.loggedIn();
                        },
                        backgroundColor: HexColor('4267B2'),
                        borderColor: HexColor('4267B2'),
                        textColor: Colors.white,
                        text: 'Link account with Facebook',
                        buttonIconData: FontAwesome5Brands.facebook_f,
                        iconColor: Colors.white,
                      ),
                    ])),
          );
  }
}
