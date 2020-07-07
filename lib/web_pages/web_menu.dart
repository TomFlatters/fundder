import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'menu_item.dart';
import 'default_button.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/models/user.dart';
import 'package:provider/provider.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/extensions/hover_extensions.dart';
import 'temparary_upload_page.dart';

class WebMenu extends StatelessWidget {
  final int selected;
  WebMenu(this.selected);

  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    final user = Provider.of<User>(context);
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          Container(
            width: MediaQuery.of(context).size.width > 550
                ? MediaQuery.of(context).size.width
                : 550,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  child: Row(children: [
                    Image.asset(
                      "assets/images/Fundder_logo.png",
                      height: 40,
                      alignment: Alignment.topCenter,
                    ),
                    MediaQuery.of(context).size.width > 650
                        ? Row(children: [
                            SizedBox(width: 10),
                            Text(
                              'Fundder',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Roboto Mono',
                                  color: selected == 0
                                      ? HexColor('000000')
                                      : HexColor('#80000000')),
                            ),
                          ])
                        : Container(),
                  ]),
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ).showCursorOnHover,
                Spacer(),
                MenuItem(
                  title: Icon(AntDesign.home,
                      color: selected == 1
                          ? HexColor('000000')
                          : HexColor('#80000000')),
                  press: () {
                    if (user != null) {
                      Navigator.pushNamed(context, '/web/feed');
                    } else {
                      Navigator.pushNamed(context, '/web/login');
                    }
                  },
                ),
                MenuItem(
                  title: Icon(AntDesign.search1,
                      color: selected == 2
                          ? HexColor('000000')
                          : HexColor('#80000000')),
                  press: () {
                    if (user != null) {
                      Navigator.pushNamed(context, '/web/search');
                    } else {
                      Navigator.pushNamed(context, '/web/login');
                    }
                  },
                ),
                MenuItem(
                  title: Icon(AntDesign.plussquareo,
                      color: selected == 3
                          ? HexColor('000000')
                          : HexColor('#80000000')),
                  press: () {
                    if (user != null) {
                      Navigator.pushNamed(context, '/web/addpost');
                    } else {
                      Navigator.pushNamed(context, '/web/login');
                    }
                  },
                ),
                MenuItem(
                  title: Icon(AntDesign.hearto,
                      color: selected == 4
                          ? HexColor('000000')
                          : HexColor('#80000000')),
                  press: () {
                    if (user != null) {
                      Navigator.pushNamed(context, '/web/activity');
                    } else {
                      Navigator.pushNamed(context, '/web/login');
                    }
                  },
                ),
                MenuItem(
                  title: Icon(AntDesign.user,
                      color: selected == 5
                          ? HexColor('000000')
                          : HexColor('#80000000')),
                  press: () {
                    if (user != null) {
                      Navigator.pushNamed(context, '/web/profile');
                    } else {
                      Navigator.pushNamed(context, '/web/login');
                    }
                  },
                ),
                DefaultButton(
                  text: user != null ? "Log out" : "Login / Register",
                  press: () async {
                    if (user != null) {
                      await _auth.signOut().then((value) {
                        Navigator.pushNamed(context, '/web/login');
                      });
                      /*Navigator.pushReplacementNamed(context, '/web/logging_out');*/
                    } else {
                      Navigator.pushNamed(context, '/web/login');
                    }
                  },
                ),
              ],
            ),
          )
        ]));
  }
}
