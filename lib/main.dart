import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:fireuser/login_system/blocs/authenticate_bloc/authenticate_bloc.dart';
import 'package:fireuser/login_system/pages/login_page.dart';
import 'package:fireuser/login_system/pages/user_page.dart';
import 'package:fireuser/login_system/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireuser/login_system/blocs/staff_bloc/staff_bloc.dart';
import 'package:fireuser/login_system/entry_point.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        Login.sName: (context) => Login(),
        User.sName: (context) => User(),
      },
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: child,
        );
      },
    ),
  );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
    );
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        check();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticateBloc>(
          create: (context) => AuthenticateBloc(userRepository: userRepository),
        ),
        BlocProvider<StaffBloc>(
          create: (context) => StaffBloc(),
        ),
      ],
      child: LoginEntry(),
    );
  }

  void check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('網路狀態警告'),
          content: Text('請確認網路是否連接。'),
          actions: <Widget>[
            TextButton(
              child: Text('確認'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }
}

var subscription;
