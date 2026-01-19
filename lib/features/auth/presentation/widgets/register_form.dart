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
import 'package:get/get.dart';

class RegisterForm extends StatelessWidget {
  final bool isLoading;
  const RegisterForm({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: fullNameController,
          label: 'Full Name',
          hint: 'John Doe',
          validator: Validators.validateFullName,
        ),
        const SizedBox(height: 28),

        AppTextField(
          controller: emailController,
          label: 'Email',
          hint: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 28),

        AppTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'Minimum 6 characters',
          obscureText: true,
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 40),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final loading = authState is AuthLoading || isLoading;

            return Container(
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: loading
                      ? null
                      : () {
                    if (emailController.text.trim().isEmpty ||
                        passwordController.text.isEmpty ||
                        fullNameController.text.trim().isEmpty) {
                      Get.snackbar(
                        'Missing Fields',
                        'Please complete all fields',
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    context.read<AuthBloc>().add(
                      RegisterRequested(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        fullName: fullNameController.text.trim(),
                      ),
                    );
                  },
                  child: Center(
                    child: loading
                        ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 15.2),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFBBDEFB),
                textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ],
    );
  }
}