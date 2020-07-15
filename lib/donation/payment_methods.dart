import 'package:flutter/material.dart';

Container paymentMethodSelection(BuildContext context, Function onItemPress) {
  return Container(
    padding: EdgeInsets.all(20),
    child: ListView.builder(
        itemBuilder: (context, index) {
          Icon icon;
          Text text;

          switch (index) {
            case 0:
              icon = Icon(Icons.add_circle, color: Colors.black);
              text = Text('Pay via new card');
              break;
            case 1:
              icon = Icon(Icons.credit_card, color: Colors.black);
              text = Text('Pay via existing card');
              break;
          }

          return ListTile(
            onTap: onItemPress(context, index),
            title: text,
            leading: icon,
          );
        },
        itemCount: 2),
  );
}
