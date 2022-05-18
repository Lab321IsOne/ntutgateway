part of 'authenticate_bloc.dart';

abstract class AuthenticateState extends Equatable {
  const AuthenticateState();

  @override
  List<Object> get props => [];
}

// state when user login failed
class AuthenticateLogInFailedState extends AuthenticateState {
  final String failureMessage;
  AuthenticateLogInFailedState({this.failureMessage});
}

// state when user login success
class AuthenticateLoggedInState extends AuthenticateState {
  final Map<String, String> loginResult;
  AuthenticateLoggedInState({this.loginResult});

  @override
  List<Object> get props => [this.loginResult];
}

// state when user logging in (for ui state change)
class AuthenticateLoggingInState extends AuthenticateState {}

// state when user is logged out
class AuthenticateLoggedOutState extends AuthenticateState {}
