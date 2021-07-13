import 'package:flutter/material.dart';

enum DialogAction { yes, abort }
enum DialogAlert { close }

class Dialogs {
  static Future<DialogAction> yesAbortDialog(
      BuildContext context, String title, String body) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 24.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              TextButton(
                child: Text("Não"),
                onPressed: () => Navigator.of(context).pop(DialogAction.abort),
              ),
              ElevatedButton(
                  child: Text("Sim", style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.of(context).pop(DialogAction.yes)),
            ],
          );
        });
    return (action != null) ? action : DialogAction.abort;
  }

  static Future<DialogAlert> alertDialog(
      BuildContext context, String title, String body) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 24.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              TextButton(
                child: Text("Fechar"),
                onPressed: () => Navigator.of(context).pop(DialogAlert.close),
              ),
            ],
          );
        });
    return (action != null) ? action : DialogAlert.close;
  }

}
