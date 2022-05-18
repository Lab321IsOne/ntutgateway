import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fireuser/login_system/blocs/authenticate_bloc/authenticate_bloc.dart';
import 'package:fireuser/login_system/pages/user_page.dart';

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final usernameController = TextEditingController(); // 醫護人員/最高權限之使用者名稱
  final passwordController = TextEditingController(); // 醫護人員/最高權限之密碼

  bool _enabled = true; // 畫面是否能操控
  bool _isPasswordVisible = false; // 是否顯示密碼，passwordController 中使用

  final infoIncompleteSnackBar = SnackBar(
    content: ListTile(
      leading: Icon(Icons.info),
      title: Text('使用者資訊未輸入完整'),
    ),
    backgroundColor: Colors.red[700],
    duration: Duration(seconds: 1, milliseconds: 500),
  );

  // 醫護人員/最高權限登入時執行
  void staffLogin() {
    final String _username =
        usernameController.text.trim(); // 取得 username TextField 內容
    final String _password =
        passwordController.text; // 取得 password TextField 內容

    // 若使用者未輸入完整則跳出訊息，並跳出函式
    if (_username.isEmpty || _password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(infoIncompleteSnackBar);
      return;
    }

    // 增加登入中事件，BlocConsumer 會接到 AuthenticateLoggingInState 的通知
    BlocProvider.of<AuthenticateBloc>(context)
        .add(AuthenticateLoggingInEvent());
    // 增加登入事件，會透過 AuthenticateBloc 送到 UserRepository 登入 Firebase 並回傳登入結果
    BlocProvider.of<AuthenticateBloc>(context).add(AuthenticateLogInEvent(
      username: _username,
      password: _password,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 5.0,
      child: BlocConsumer<AuthenticateBloc, AuthenticateState>(
        listener: (context, state) {
          if (state is AuthenticateLoggedInState) {
            // 登入成功則切換畫面至 User
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => User(),
            ));
          } else {
            SnackBar snackBar;
            if (state is AuthenticateLoggingInState) {
              // 等待 Firebase 登入結果時跳出
              snackBar = SnackBar(
                content: ListTile(
                  leading: Icon(Icons.whatshot),
                  title: Text('登入中，請稍候...'),
                ),
                backgroundColor: Colors.teal[700],
                duration: Duration(seconds: 1, milliseconds: 500),
              );
            } else if (state is AuthenticateLogInFailedState) {
              // 登入失敗時跳出
              snackBar = SnackBar(
                content: ListTile(
                  leading: Icon(Icons.info),
                  title: Text(state.failureMessage),
                ),
                backgroundColor: Colors.red[700],
                duration: Duration(seconds: 1, milliseconds: 500),
              );
            }
            // 顯示 snackbar
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          // 登入中或者登入成功則 disable LoginCard
          _enabled = !(state is AuthenticateLoggingInState ||
              state is AuthenticateLoggedInState);
          return Column(
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                leading: (Icon(Icons.assignment_ind)),
                title: Text('醫護人員登入'),
                trailing: Card(
                  color: Colors.tealAccent,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("中繼器 APP"),
                      ],
                    ),
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: _enabled,
                          keyboardType: TextInputType.text,
                          controller: usernameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            hintText: '帳號',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: _enabled,
                          keyboardType: TextInputType.text,
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.https),
                            suffixIcon: IconButton(
                              icon: _isPasswordVisible
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() =>
                                    _isPasswordVisible = !_isPasswordVisible);
                              },
                            ),
                            hintText: '密碼',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text('登入'),
                          onPressed: (_enabled ? staffLogin : null),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class Login extends StatelessWidget {
  static const sName = "/login_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
        toolbarHeight: 0,
      ),
      backgroundColor: Colors.lightBlue[100],
      body: SafeArea(
        child: SingleChildScrollView(
          // SingleChildScrollView: widget overflow 時可以滾動畫面
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 44.0),
              Text(
                'NTUT Lab 321',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '點滴尿袋智慧監控系統',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Image.asset(
                'images/NTUT-logo.png',
                height: 200.0,
                width: 200.0,
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: LoginCard(), // 輸入帳號資料/流水號的 Card
              ),
              SizedBox(height: 20.0),
              Text(
                '特別感謝：台北榮民醫院 - 蘇澳暨員山分院 協助開發',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Gateway v1.3.0',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
