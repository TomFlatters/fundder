import 'package:flutter/material.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/which_charity_input.dart';
import 'package:provider/provider.dart';
import 'tile_widgets/charity_tiles.dart';
import 'package:fundder/shared/loading.dart';

class ChooseCharity extends StatefulWidget {
  final Function charitySelected;
  List<Charity> charities;
  int charity;
  ChooseCharity({this.charitySelected, this.charities, this.charity});
  @override
  _ChooseCharityState createState() => _ChooseCharityState();
}

class _ChooseCharityState extends State<ChooseCharity> {
  int selectedCharity;

  @override
  void initState() {
    selectedCharity = widget.charity;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final charityState =
        Provider.of<CharitySelectionStateManager>(context, listen: false);
    charityState.setCharityList(widget.charities);
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
                        return CharityTile(widget.charities[index],
                            selectedCharity == index ? true : false, () {
                          widget.charitySelected(index);
                          setState(() {
                            this.selectedCharity = index;
                          });
                        });
                      })
                  : Loading()
            ],
          )),
    ]);
  }
}
