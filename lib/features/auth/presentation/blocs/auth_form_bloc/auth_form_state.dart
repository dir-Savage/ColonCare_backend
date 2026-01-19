import 'package:equatable/equatable.dart';

class AuthFormState extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final bool isSubmitting;
  final bool showErrorMessages;
  final bool isLoginForm;
  final String? errorMessage;

  const AuthFormState({
    this.email = '',
    this.password = '',
    this.fullName = '',
    this.isSubmitting = false,
    this.showErrorMessages = false,
    this.isLoginForm = true,
    this.errorMessage,
  });

  bool get isEmailValid {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool get isPasswordValid => password.length >= 6;

  bool get isFullNameValid => fullName.length >= 3;

  bool get isLoginFormValid => isEmailValid && isPasswordValid;

  bool get isRegisterFormValid => isEmailValid && isPasswordValid && isFullNameValid;

  bool get isFormValid => isLoginForm ? isLoginFormValid : isRegisterFormValid;

  AuthFormState copyWith({
    String? email,
    String? password,
    String? fullName,
    bool? isSubmitting,
    bool? showErrorMessages,
    bool? isLoginForm,
    String? errorMessage,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showErrorMessages: showErrorMessages ?? this.showErrorMessages,
      isLoginForm: isLoginForm ?? this.isLoginForm,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    fullName,
    isSubmitting,
    showErrorMessages,
    isLoginForm,
    errorMessage,
  ];
}