import 'package:flutter/material.dart';

Future<void> dialog(BuildContext context, String text) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.orange),
            Text(' Peringatan '),
            Icon(Icons.warning, color: Colors.orange),
          ],
        ),
        content: new Text(text, textAlign: TextAlign.center),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
