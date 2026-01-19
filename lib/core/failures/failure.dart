import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Invalid email or password');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('Email already in use');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('Password is too weak');
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure() : super('Network error occurred');
}

// Storage Failures
class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}