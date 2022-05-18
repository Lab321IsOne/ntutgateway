import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:fireuser/login_system/user_repository.dart';

part 'authenticate_event.dart';

part 'authenticate_state.dart';

class AuthenticateBloc extends Bloc<AuthenticateEvent, AuthenticateState> {
  final UserRepository _userRepository;

  AuthenticateBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(AuthenticateLoggedOutState());

  @override
  Stream<AuthenticateState> mapEventToState(
    AuthenticateEvent event,
  ) async* {
    if (event is AuthenticateLogInEvent) {
      yield* _mapAuthenticateLogInEventToState(
        event.username,
        event.password,
      );
    } else if (event is AuthenticateLogOutEvent) {
      yield* _mapAuthenticateLogOutToState();
    } else if (event is AuthenticateLogInFailedEvent) {
      yield* _mapAuthenticateLogInFailedEventToState(
        event.message,
      );
    } else if (event is AuthenticateLoggingInEvent) {
      yield* _mapAuthenticateLoggingInEventToState();
    }
  }

  Stream<AuthenticateState> _mapAuthenticateLogInEventToState(
    String username,
    String password,
  ) async* {
    final bool isLoggedIn = _userRepository.isLoggedIn();
    Map loginResult;

    if (isLoggedIn) {
      print(
          '@authenticate_bloc.dart -> _mapAuthenticateLogInEventToState -> user already logged in');
    } else {
      // login via user_repository.dart
      try {
        loginResult = await _userRepository.logInWithUsernameAndPassword(
          username: username,
          password: password,
        );

        if (loginResult == null) {
          yield AuthenticateLogInFailedState(
              failureMessage: '使用者名稱錯誤或是密碼錯誤，請再試一次');
          throw Exception;
        }
      } on Exception catch (e) {
        print(e);
        yield AuthenticateLogInFailedState(failureMessage: '連線至伺服器時發生錯誤，請再試一次');
      }
    }
    yield AuthenticateLoggedInState(loginResult: loginResult);
  }

  Stream<AuthenticateState> _mapAuthenticateLogOutToState() async* {
    final bool isLoggedIn = _userRepository.isLoggedIn();
    if (isLoggedIn) {
      _userRepository.logOut();
    } else {
      print(
          '@authenticate_bloc -> _mapAuthenticateLogOutToState -> user is already null');
    }
    yield AuthenticateLoggedOutState();
  }

  Stream<AuthenticateState> _mapAuthenticateLogInFailedEventToState(
      String message) async* {
    yield AuthenticateLogInFailedState(failureMessage: message);
  }

  Stream<AuthenticateState> _mapAuthenticateLoggingInEventToState() async* {
    yield AuthenticateLoggingInState();
  }
}
