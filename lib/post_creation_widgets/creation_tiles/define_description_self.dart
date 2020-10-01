import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:fundder/helper_classes.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/shared/constants.dart';

class DefineDescriptionSelf extends StatefulWidget {
  final Function(String) onSubtitleChange;
  final Function(String) onTitleChange;
  final Function(String) onMoneyChange;
  final Function nextPage;
  final String title;
  final String subtitle;
  final String money;
  DefineDescriptionSelf(
      {this.onSubtitleChange,
      this.onTitleChange,
      this.onMoneyChange,
      this.nextPage,
      this.title,
      this.subtitle,
      this.money});
  @override
  _DefineDescriptionSelfState createState() => _DefineDescriptionSelfState();
}

class _DefineDescriptionSelfState extends State<DefineDescriptionSelf> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final moneyController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  @override
  void initState() {
    titleController.text = widget.title;
    subtitleController.text = widget.subtitle;
    moneyController.text = widget.money;

    moneyController.afterChange = (String masked, double raw) {
      widget.onMoneyChange(masked);
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: <Widget>[
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
                Container(
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontFamily: 'Founders Grotesk',
                          ),
                          children: [
                        TextSpan(
                            text: 'Title of Challenge ',
                            style: TextStyle(
                              fontFamily: 'Founders Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                        TextSpan(
                            text: 'maximum 50 characters',
                            style: TextStyle(
                              fontFamily: 'Founders Grotesk',
                              fontSize: 12,
                            ))
                      ])),
                ),
                TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  controller: titleController,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Eg. Hatford XV performs California Girls',
                  ),
                  onChanged: widget.onTitleChange,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                  controller: subtitleController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Eg. We will sing @Cornmarket St 12pm Sunday'),
                  onChanged: widget.onSubtitleChange,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    'If',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Row(children: [
                  Text(
                    '£',
                    style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontFamily: 'Founders Grotesk',
                        fontSize: 45,
                        color: HexColor('ff6b6c')),
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontFamily: 'Founders Grotesk',
                        fontSize: 45,
                        color: Colors.black,
                      ),
                      controller: moneyController,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Amount in £'),
                    ),
                  )
                ]),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'is donated to',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                PrimaryFundderButton(
                  onPressed: widget.nextPage,
                  text: "Set Charity",
                )
              ])),
    ]);
  }
}
