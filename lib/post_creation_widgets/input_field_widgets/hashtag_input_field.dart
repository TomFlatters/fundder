import 'package:flutter/material.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/set_hashtags.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_interface.dart';
import 'package:provider/provider.dart';

class HashtagsStateManager {
  List<String> _hashtags = [];
  List<String> get currentValue {
    return _hashtags;
  }

  void updateValue(List<String> newHashtags) {
    _hashtags = newHashtags;
    print("The list of hashtags are: " +
        _hashtags.toString() +
        " and the validity status is $isInputValid");
  }

  bool get isInputValid {
    return (_hashtags.length >= 2);
  }
}

class HashtagsInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HashtagsStateManager>(builder: (_, state, __) {
      return SetHashtags(
          hashtags: state.currentValue, onHasthagChange: state.updateValue);
    });
  }
}
