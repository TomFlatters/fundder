import 'package:flutter/material.dart';
import 'terms_of_use_text.dart';

class TermsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Terms of Use'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(null),
            )
          ],
          leading: new Container(),
        ),
        body: TermsOfUseText());
  }
}
