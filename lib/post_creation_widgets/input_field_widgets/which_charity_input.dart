import 'package:flutter/material.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/choose_charity.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_interface.dart';

class CharitySelectionField extends InputField {
  final List<Charity> charities;
  int _selectedCharity = -1;
  bool get isInputValid {
    return (_selectedCharity > -1);
  }

  _setChosenCharity(int charityNo) {
    _selectedCharity = charityNo;
    print(
        "Selected charity is $charityNo and validty status is now $isInputValid");
  }

  StatefulWidget buildWidget() {
    return ChooseCharity(
      charitySelected: _setChosenCharity,
      charities: this.charities,
      charity: _selectedCharity,
    );
  }

  CharitySelectionField({
    @required this.charities,
  });
}

/*
class CharitySelectionList extends StatefulWidget {
  final Function onCharitySelected;
  final List<Charity> charities;
  CharitySelectionList(
      {@required this.onCharitySelected, @required this.charities});
  @override
  _CharitySelectionListState createState() => _CharitySelectionListState();
}

class _CharitySelectionListState extends State<CharitySelectionList> {
  int _chosenCharity = -1;
  @override
  Widget build(BuildContext context) {
    return ChooseCharity(charitySelected: widget ,);
  }
}
*/
