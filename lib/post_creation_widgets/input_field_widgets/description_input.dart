import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_interface.dart';
import 'package:fundder/shared/constants.dart';

class DescriptionInputField extends InputField {
  String _description;

  bool get isInputValid {
    return (_description != null && _description.length > 0);
  }

  void _onDescriptionChange(String description) {
    _description = description;
    print("new title is: $description");
    print("validity status for title input is now: ${this.isInputValid}");
  }

  StatefulWidget buildWidget() {
    //TO BE IMPLEMENTED;
    return DescriptionInputBox(
      onDescriptionChanged: _onDescriptionChange,
    );
  }
}

class DescriptionInputBox extends StatefulWidget {
  final Function onDescriptionChanged;
  DescriptionInputBox({@required this.onDescriptionChanged});
  @override
  _DescriptionInputBoxState createState() => _DescriptionInputBoxState();
}

class _DescriptionInputBoxState extends State<DescriptionInputBox> {
  Function onDescriptionChange;
  final descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    this.onDescriptionChange = widget.onDescriptionChanged;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: textInputDecoration.copyWith(
                hintText: 'As it says on the tin... '),
            onChanged: onDescriptionChange,
          ),
        ]);
  }
}
