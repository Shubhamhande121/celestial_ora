import 'package:flutter/material.dart';

showWarningDialog(onPressed, title, content, context, VoidCallback onCancel) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          titlePadding: EdgeInsets.only(top: 15, left: 10, bottom: 7),
          title: Text(title),
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
          content: Text(
            content,
            textAlign: TextAlign.center,
          ),  
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(onPressed: onCancel, child: Text("No")),
            Container(
              width: MediaQuery.of(context).size.width * .23,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(17)))),
                  onPressed: onPressed,
                  child: Text("Yes")),
            ),
          ],
        );
      });
}
