import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String statusText;
  final Color infoColor;
  final Color backgroundColor;
  final IconData iconData;

  const StatusCard({Key key, this.statusText, this.infoColor, this.backgroundColor, this.iconData});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: backgroundColor,
      elevation: 5.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        leading: Icon(
          iconData,
          color: infoColor,
          size: 44.0,
        ),
        title: Text(
          statusText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: infoColor,
          ),
        ),
      ),
    );
  }
}