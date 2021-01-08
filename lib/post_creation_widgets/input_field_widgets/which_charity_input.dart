import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/dialogs.dart';

import 'package:fundder/models/charity.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/choose_charity.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_validity_interface.dart';
import 'package:provider/provider.dart';

/**UI for selcting charity. Contains a lot of legacy code in the 'ChooseCharity'
 * A Provider providing 'CharitySelectionStateManager' must be placed above in the 
 * widget tree.
 */
class CharitySelectionField extends StatelessWidget {
  final List<Charity> charities;
  CharitySelectionField({
    @required this.charities,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<CharitySelectionStateManager>(
      builder: (_, state, __) => ChooseCharity(
          charitySelected: state.updateValue,
          charities: this.charities,
          charity: state.currentValue),
    );
  }
}

/**Holds the state for which charity has been selected. */
class CharitySelectionStateManager
    with ChangeNotifier, InputFieldValidityChecker {
  List<Charity> _charities = [];

  /**
   * 
   * Numerical index of the currently chosen charity. It's 
   * -1 if no charity is currently chosen.
   * 
   * */

  int _selected = -1;

  /**
   * Gets the index of currently selected charity (presumably from the list of 
   * charities queried from firebase)
   *  */
  int get currentValue {
    return _selected;
  }

/**
 * Updates the numerical index of the currently chosen charity to 
 * newCharityIndex.
 */

  void updateValue(int newCharityIndex) {
    print("the charity selected is now $newCharityIndex");
    _selected = newCharityIndex;
    notifyListeners();
  }

  bool get isInputValid {
    return _selected > -1;
  }

  void createErrorDialog(context) {
    DialogManager().createDialog(
      'Error',
      'You have not chosen a charity for your Fundder.',
      context,
    );
  }

  /**Sets the list of actual charities. This can only be initialised after the user
   * has  actually chosen the charity as the charity selection screen loads up 
   * the charities list from Firestore.
   */

  void setCharityList(List<Charity> newCharities) {
    _charities = newCharities;
    print("Charity list added to state; ${charityList.toString()}");
  }

/**This will only give the list of charities if the user has actually chosen a 
 * charity from the charity selection screen, due to awkward implementation. 
 * Soz...
 */
  List<Charity> get charityList => this._charities;
}