import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_interface.dart';
import 'package:fundder/shared/constants.dart';

class TitleInputField extends InputField {
  String _title;

  bool get isInputValid {
    return (_title != null && _title.length > 0);
  }

  void _onTitleChange(String newTitle) {
    _title = newTitle;
    print("new title is: ${newTitle}");
    print("validity status for title input is now: ${this.isInputValid}");
  }

  StatefulWidget buildWidget() {
    //TO BE IMPLEMENTED;
    return TitleInputBox(
      onTitleChange: _onTitleChange,
    );
  }
}

class TitleInputBox extends StatefulWidget {
  final Function onTitleChange;
  TitleInputBox({@required this.onTitleChange});
  @override
  _TitleInputBoxState createState() => _TitleInputBoxState();
}

class _TitleInputBoxState extends State<TitleInputBox> {
  Function onTitleChange;
  final titleController = TextEditingController();
  @override
  void initState() {
    super.initState();
    this.onTitleChange = widget.onTitleChange;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      text: 'maximum 80 characters',
                      style: TextStyle(
                        fontFamily: 'Founders Grotesk',
                        fontSize: 12,
                      ))
                ])),
          ),
          TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(80),
            ],
            controller: titleController,
            decoration: textInputDecoration.copyWith(
              hintText:
                  'I will shop with just my underwear at Sainsbury\'s *for charity* :))',
            ),
            onChanged: onTitleChange,
          ),
        ]);
  }
}
