import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';

class PrivacyIcon extends StatefulWidget {
  final bool isPrivate;
  final Function onPrivacySettingChanged;
  final String description;
  PrivacyIcon(
      {@required this.isPrivate,
      @required this.onPrivacySettingChanged,
      @required this.description});
  @override
  _PrivacyIconState createState() => _PrivacyIconState();
}

class _PrivacyIconState extends State<PrivacyIcon> {
  bool _isPrivate;
  @override
  void initState() {
    this._isPrivate = widget.isPrivate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("_isPrivate = " + _isPrivate.toString());
    return SwitchListTile(
      activeColor: HexColor('ff6b6c'),
      value: _isPrivate,
      onChanged: (newValue) => {
        setState(() {
          _isPrivate = newValue;
          widget.onPrivacySettingChanged(newValue);
        })
      },
      secondary: Icon(Icons.lock_outline),
      title: Text('Private Mode'),
      subtitle: Text(widget.description),
    );
  }
}
