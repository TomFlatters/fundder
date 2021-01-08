import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Fund3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Creating Fundders',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: 'Founders Grotesk',
                  ),
                  children: [
                    TextSpan(
                        text: 'To add your own Fundder to the ',
                        style: TextStyle()),
                    TextSpan(
                        text:
                            'feed, you can either create your own by pressing',
                        style: TextStyle()),
                  ])),
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Icon(
                  AntDesign.plussquareo,
                  color: HexColor('ff6b6c'),
                  size: 40,
                ),
              ),
            ),
          ),
          Text(
              "in the bottom bar. You can challenge people to Fundders by pressing",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal)),
          Expanded(
            child: Center(
                child: Container(
              margin: EdgeInsets.all(10),
              child: Icon(
                MdiIcons.sword,
                color: HexColor('ff6b6c'),
                size: 40,
              ),
            )),
          ),
        ]);
  }
}
