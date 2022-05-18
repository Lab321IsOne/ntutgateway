part of 'authenticate_bloc.dart';

abstract class AuthenticateEvent extends Equatable {
  const AuthenticateEvent();
}

// logging in event that yields state for ui change
class AuthenticateLoggingInEvent extends AuthenticateEvent {
  @override
  List<Object> get props => [];
}

// login event via UserRepository (for staff/admin)
class AuthenticateLogInEvent extends AuthenticateEvent {
  final String username, password;

  const AuthenticateLogInEvent({
    this.username,
    this.password,
  })  : assert(username != null),
        assert(password != null);

  @override
  List<Object> get props => [
        this.username,
        this.password,
      ];
}

// login event via api.dart (for guest)
class SerialNumberLogInEvent extends AuthenticateEvent {
  final String serialNumber;

  const SerialNumberLogInEvent({this.serialNumber})
      : assert(serialNumber != null);

  @override
  List<Object> get props => [this.serialNumber];
}

// logout event that yields state for ui change
class AuthenticateLogOutEvent extends AuthenticateEvent {
  @override
  List<Object> get props => [];
}

// login fail event that yields state for ui change
class AuthenticateLogInFailedEvent extends AuthenticateEvent {
  final String message;

  const AuthenticateLogInFailedEvent({this.message});

  @override
  List<Object> get props => [this.message];
}
