import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/shared/constants.dart';

class SetHashtags extends StatefulWidget {
  /**List of hashtags selected by the user.
   * It always has the most up to date hashtags.
   */
  final List<String> hashtags;
  final Function(List<String>) onHasthagChange;
  SetHashtags({this.hashtags, this.onHasthagChange});
  @override
  _SetHashtagsState createState() => _SetHashtagsState();
}

class _SetHashtagsState extends State<SetHashtags> {
  final hashtagController = TextEditingController();

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
                Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontFamily: 'Founders Grotesk',
                            ),
                            children: [
                          TextSpan(
                              text:
                                  'Add some hashtags to help categorise your post ',
                              style: TextStyle(
                                fontFamily: 'Founders Grotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                          TextSpan(
                              text:
                                  "minimum 2, maximum 5. Press 'add' after every hashtag you would like to add.",
                              style: TextStyle(
                                fontFamily: 'Founders Grotesk',
                                fontSize: 12,
                              )),
                        ]))),
                Row(children: [
                  Expanded(
                      child: TextField(
                          inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                      ],
                          controller: hashtagController,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          decoration: textInputDecoration.copyWith(
                              hintText:
                                  'Only text allowed, press add for each hashtag'))),
                  widget.hashtags.length < 5
                      ? FlatButton(
                          onPressed: () {
                            if (widget.hashtags
                                        .contains(hashtagController.text) ==
                                    false &&
                                hashtagController.text != "") {
                              if (mounted) {
                                setState(() {
                                  widget.hashtags.add(
                                      hashtagController.text.toLowerCase());
                                  widget.onHasthagChange(widget.hashtags);
                                  hashtagController.text = "";
                                });
                              }
                            }
                          },
                          child: Text('Add'))
                      : Container()
                ]),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.hashtags.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        dense: true,
                        title: Text("#" + widget.hashtags[index]),
                        trailing: FlatButton(
                          child: Text('Delete',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              )),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                widget.hashtags.removeAt(index);
                                widget.onHasthagChange(widget.hashtags);
                              });
                            }
                          },
                        ),
                      );
                    })
              ]))
    ]);
  }
}
