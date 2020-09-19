import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefineDescriptionOthers extends StatefulWidget {
  final Function(String) onSubtitleChange;
  final Function(String) onTitleChange;
  final String title;
  final String subtitle;
  DefineDescriptionOthers(
      {this.onSubtitleChange, this.onTitleChange, this.title, this.subtitle});
  @override
  _DefineDescriptionOthersState createState() =>
      _DefineDescriptionOthersState();
}

class _DefineDescriptionOthersState extends State<DefineDescriptionOthers> {
  void initState() {
    titleController.text = widget.title;
    subtitleController.text = widget.subtitle;

    super.initState();
  }

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
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
                            text: "Title of Challenge ",
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
                  decoration: InputDecoration(
                    hintText: 'Eg. Perform California Girls by Katy Perry',
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
                  decoration:
                      InputDecoration(hintText: 'Eg. Sing on a crowded street'),
                  onChanged: widget.onSubtitleChange,
                ),
              ]))
    ]);
  }
}
