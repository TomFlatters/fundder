import 'package:flutter/cupertino.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/which_charity_input.dart';
import 'package:fundder/post_creation_widgets/screens/screen_interface.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/loading.dart';

/**Screen giving option to select charity. This is the second add post 
 * screen.
 */

class CharitySelectionScreen extends StatelessWidget {
  bool get allFieldsValid {
    //TODO: to be implemented by logical conjunction of the validity of all input fields.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseService(uid: "123").getCharityNameList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Charity> charities = snapshot.data;
            return CharitySelectionField(charities: charities);
          } else {
            return Center(
              child: Loading(),
            );
          }
        });
  }
}
