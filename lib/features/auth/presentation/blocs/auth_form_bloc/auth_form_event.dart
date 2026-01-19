import 'package:equatable/equatable.dart';

abstract class AuthFormEvent extends Equatable {
  const AuthFormEvent();

  @override
  List<Object> get props => [];
}

// Update email
class EmailChanged extends AuthFormEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

// Update password
class PasswordChanged extends AuthFormEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

// Update full name
class FullNameChanged extends AuthFormEvent {
  final String fullName;

  const FullNameChanged(this.fullName);

  @override
  List<Object> get props => [fullName];
}

// Form submitted
class FormSubmitted extends AuthFormEvent {
  final bool isLogin;

  const FormSubmitted({required this.isLogin});

  @override
  List<Object> get props => [isLogin];
}

// Reset form
class FormReset extends AuthFormEvent {}