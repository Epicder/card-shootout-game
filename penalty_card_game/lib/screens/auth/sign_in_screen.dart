import 'package:penalty_card_game/screens/auth/components/my_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/sign_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          setState(() {
            signInRequired = false;
          });
        } else if (state is SignInProcess) {
          setState(() {
            signInRequired = true;
          });
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
            _errorMsg = 'Invalid email or password';
          });
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // Proporción horizontal
              vertical: screenHeight * 0.02, // Proporción vertical
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.01),
                Container(
                  width: screenWidth * 0.36,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(91, 196, 95, 0.7),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 38, // Set your desired height here
                        child: MyTextField(
                          controller: emailController,
                          hintText: 'Email',
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(CupertinoIcons.mail_solid),
                          errorMsg: _errorMsg,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$')
                                .hasMatch(val)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 38, // Set your desired height here
                        child: MyTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          prefixIcon: const Icon(CupertinoIcons.lock_fill),
                          errorMsg: _errorMsg,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$')
                                .hasMatch(val)) {
                              return 'Please enter a valid password';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                                iconPassword = obscurePassword
                                    ? CupertinoIcons.eye_fill
                                    : CupertinoIcons.eye_slash_fill;
                              });
                            },
                            icon: Icon(iconPassword),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                !signInRequired
                    ? SizedBox(
                        width: screenWidth * 0.14, // Botón ajustado al 50% del ancho
                        child: TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<SignInBloc>().add(SignInRequired(
                                    emailController.text,
                                    passwordController.text,
                                  ));
                            }
                          },
                          style: TextButton.styleFrom(
                            elevation: 3.0,
                            backgroundColor:
                                const Color.fromRGBO(91, 196, 95, 1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            child: Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}