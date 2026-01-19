import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'auth_form_event.dart';
import 'auth_form_state.dart';

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  AuthFormBloc() : super(const AuthFormState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<FullNameChanged>(_onFullNameChanged);
    on<FormSubmitted>(_onFormSubmitted);
    on<FormReset>(_onFormReset);
  }

  void _onEmailChanged(
      EmailChanged event,
      Emitter<AuthFormState> emit,
      ) {
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(
      PasswordChanged event,
      Emitter<AuthFormState> emit,
      ) {
    emit(state.copyWith(password: event.password));
  }

  void _onFullNameChanged(
      FullNameChanged event,
      Emitter<AuthFormState> emit,
      ) {
    emit(state.copyWith(fullName: event.fullName));
  }

  void _onFormSubmitted(
      FormSubmitted event,
      Emitter<AuthFormState> emit,
      ) {
    emit(state.copyWith(
      isSubmitting: true,
      showErrorMessages: true,
      isLoginForm: event.isLogin,
    ));
  }

  void _onFormReset(
      FormReset event,
      Emitter<AuthFormState> emit,
      ) {
    emit(const AuthFormState());
  }
}