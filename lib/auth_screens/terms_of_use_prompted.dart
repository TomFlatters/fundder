import 'package:flutter/material.dart';
import 'terms_of_use_text.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/global_widgets/buttons.dart';

class TermsViewPrompter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text('Our terms of use'),
            actions: <Widget>[
              FlatButton(
                child: Text('Accept',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
            leading: Container()),
        body: Column(children: [
          Expanded(child: TermsOfUseText()),
          SizedBox(
            height: 12,
          ),
          PrimaryFundderButton(
            onPressed: () => Navigator.of(context).pop(true),
            text: 'Accept',
          ),
          SizedBox(height: 20),
          EditFundderButton(
            onPressed: () {
              DialogManager().showChoiceDialog(
                  'Terms Rejected',
                  'Unfortunately, you cannot use Fundder without accepting the terms of use. You will now be logged out',
                  context, <Widget>[
                FlatButton(
                    child: Text('Reject',
                        style: TextStyle(color: HexColor('ff6b6c'))),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(Navigator.of(context).pop(false));
                    }),
                FlatButton(
                    child: Text('Cancel',
                        style: TextStyle(color: HexColor('ff6b6c'))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]);
            },
            text: 'Reject',
          ),
          SizedBox(height: 40)
        ]));
  }
}
