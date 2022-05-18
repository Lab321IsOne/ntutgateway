import 'package:fireuser/login_system/custom_widgets/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fireuser/login_system/blocs/authenticate_bloc/authenticate_bloc.dart';
import 'package:fireuser/page_bluetooth/bluetooth.dart';

class User extends StatelessWidget {
  static const sName = "/user_page";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticateBloc, AuthenticateState>(
      builder: (context, state) {
        if (state is AuthenticateLoggedInState) {
          final Map userData = state.loginResult; // 從 AuthenticateState 取得登入者資料
          switch (userData['role']) {
            // 取得登入者權限
            case 'administrator': // 最高權限
              return PageBluetooth();
            case 'staff': // 醫護人員
              return PageBluetooth();
            default:
              // 錯誤處理
              return Scaffold(
                appBar: null,
                body: MessageScreen(
                  child: Icon(Icons.error_outline),
                  message: '使用者資訊出現問題',
                ),
              );
          }
        } else {
          // 錯誤處理
          return Scaffold(
            appBar: null,
            body: MessageScreen(
              child: Icon(Icons.error_outline),
              message: '登入時出現問題',
            ),
          );
        }
      },
    );
  }
}
