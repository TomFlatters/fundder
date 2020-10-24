import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'tile_widgets/who_do_tiles.dart';

class ChoosePerson extends StatelessWidget {
  final ValueChanged<int> chooseSelected;
  final int selected;
  ChoosePerson({this.selected, this.chooseSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.grey[200],
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: 10),
              ),
            ),
            Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                child: Text(
                  'Who do you want to do it',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
            GestureDetector(
              onTap: () {
                chooseSelected(0);
              },
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 300,
                  decoration: BoxDecoration(
                      border: selected == 0
                          ? Border.all(color: HexColor('ff6b6c'), width: 3)
                          : Border.all(color: Colors.grey[200], width: 3),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: MyselfTile(selected == 0
                      ? HexColor('ff6b6c') //Color.fromRGBO(237, 106, 110, .3)
                      : Colors.grey[200])),
            ),
            SizedBox(height: 20),
            Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  'Or',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                chooseSelected(1);
              },
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      border: selected == 1
                          ? Border.all(color: HexColor('ff6b6c'), width: 3)
                          : Border.all(color: Colors.grey[200], width: 3),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: OthersTile(selected == 1
                      ? HexColor('ff6b6c') //Color.fromRGBO(237, 106, 110, .3)
                      : Colors.grey[200])),
            ),
            SizedBox(height: 10),
          ],
        ));
  }
}
