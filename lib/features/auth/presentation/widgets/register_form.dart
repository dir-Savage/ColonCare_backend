import 'package:coloncare/core/utils/validators.dart';
import 'package:coloncare/core/widgets/app_button.dart';
import 'package:coloncare/core/widgets/app_text_field.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_form_bloc/auth_form_bloc.dart';
import 'package:coloncare/features/auth/presentation/blocs/auth_form_bloc/auth_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class RegisterForm extends StatelessWidget {
  final bool isLoading;
  const RegisterForm({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController();

    return BlocBuilder<AuthFormBloc, AuthFormState>(
      builder: (context, formState) {
        return SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                AppTextField(
                  controller: fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  validator: Validators.validateFullName,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Enter your password (min. 6 characters)',
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 30),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return AppButton(
                      text: 'Create Account',
                      onPressed: () {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            fullNameController.text.isEmpty) {
                          // Local validation snackbar (optional)
                          Get.snackbar(
                            'Error',
                            'Please fill all fields',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(
                          RegisterRequested(
                            email: emailController.text,
                            password: passwordController.text,
                            fullName: fullNameController.text,
                          ),
                        );
                      },
                      isLoading: authState is AuthLoading || isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}