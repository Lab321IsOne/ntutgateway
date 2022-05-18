import 'package:flutter/material.dart';
//import 'package:fireuser/login_system/blocs/authenticate_bloc/authenticate_bloc.dart';
import 'package:fireuser/login_system/pages/login_page.dart';
import 'package:fireuser/login_system/pages/user_page.dart';
// import 'package:fireuser/login_system/user_repository.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:fireuser/login_system/blocs/staff_bloc/staff_bloc.dart';
import 'package:fireuser/page_bluetooth/bluetooth.dart';

class LoginEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Login.sName,
      //initialRoute: PageBluetooth.sName,
      routes: {
        Login.sName: (context) => Login(),
        User.sName: (context) => User(),
        PageBluetooth.sName: (context) => PageBluetooth(),
      },
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: child,
        );
      },
    );
  }
}
