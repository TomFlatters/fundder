import 'package:flutter/material.dart';
import 'package:fundder/models/charity.dart';
import 'tile_widgets/charity_tiles.dart';
import 'package:fundder/shared/loading.dart';

class ChooseCharity extends StatefulWidget {
  final ValueChanged<int> charitySelected;
  List<Charity> charities;
  int charity;
  ChooseCharity({this.charitySelected, this.charities, this.charity});
  @override
  _ChooseCharityState createState() => _ChooseCharityState();
}

class _ChooseCharityState extends State<ChooseCharity> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
        ),
      ),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Which charity are you raising for?',
                style: TextStyle(
                  fontFamily: 'Founders Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              widget.charities != null
                  ? ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                            height: 10,
                          ),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      shrinkWrap: true,
                      itemCount: widget.charities != null
                          ? widget.charities.length
                          : 0,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          child: CharityTile(widget.charities[index],
                              widget.charity == index ? true : false),
                          onTap: () {
                            widget.charitySelected(index);
                          },
                        );
                      })
                  : Loading()
            ],
          )),
    ]);
  }
}
