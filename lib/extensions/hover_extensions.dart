import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

extension HoverExtensions on Widget {
  // Get a regerence to the body of the view
  static final appContainer =
      html.window.document.querySelectorAll('flt-glass-pane')[0];
  Widget get showCursorOnHover {
    if (kIsWeb == true) {
      return MouseRegion(
        child: this,
        // When the mouse enters the widget set the cursor to pointer
        onHover: (event) {
          appContainer.style.cursor = 'pointer';
        },
        // When it exits set it back to default
        onExit: (event) {
          appContainer.style.cursor = 'default';
        },
      );
    } else {
      return Container();
    }
  }
}
