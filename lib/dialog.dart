import 'package:flutter/material.dart';

class MessageHUD  {

  static void showHUD(BuildContext context,String message){

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          String alertText = message;
          return AlertDialog(
              content: Row(
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                ],
              ));
        });
  }

  static void showNoLoadingHUD(BuildContext context,String message){

    showDialog(
        context: context,
        builder: (context) {
          String alertText = message;
          return AlertDialog(
              content: Text(alertText),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('确定'),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ]
          );
        });
  }
}