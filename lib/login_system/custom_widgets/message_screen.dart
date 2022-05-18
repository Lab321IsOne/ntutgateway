import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  final Widget child;
  final String message;

  const MessageScreen({Key key, @required this.child, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            SizedBox(height: 20.0),
            Text(message, style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
