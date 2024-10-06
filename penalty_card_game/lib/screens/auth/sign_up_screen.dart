import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../blocs/sign_up_bloc/sign_up_bloc.dart';
import 'components/my_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
	final passwordController = TextEditingController();
  final emailController = TextEditingController();
	final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
	IconData iconPassword = CupertinoIcons.eye_fill;
	bool obscurePassword = true;
	bool signUpRequired = false;

	bool containsUpperCase = false;
	bool containsLowerCase = false;
	bool containsNumber = false;
	bool containsSpecialChar = false;
	bool contains8Length = false;

  @override
Widget build(BuildContext context) {
  return BlocListener<SignUpBloc, SignUpState>(
    listener: (context, state) {
      if (state is SignUpSuccess) {
        setState(() {
          signUpRequired = false;
        });
      } else if (state is SignUpProcess) {
        setState(() {
          signUpRequired = true;
        });
      } else if (state is SignUpFailure) {
        return;
      }
    },
    child: Form(
      key: _formKey,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(91, 196, 95, 0.7), // Fondo verde
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(CupertinoIcons.mail_solid),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(val)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      prefixIcon: const Icon(CupertinoIcons.lock_fill),
                      onChanged: (val) {
                        // Validaciones de la contraseña
                        if (val!.contains(RegExp(r'[A-Z]'))) {
                          setState(() {
                            containsUpperCase = true;
                          });
                        } else {
                          setState(() {
                            containsUpperCase = false;
                          });
                        }
                        if (val.contains(RegExp(r'[a-z]'))) {
                          setState(() {
                            containsLowerCase = true;
                          });
                        } else {
                          setState(() {
                            containsLowerCase = false;
                          });
                        }
                        if (val.contains(RegExp(r'[0-9]'))) {
                          setState(() {
                            containsNumber = true;
                          });
                        } else {
                          setState(() {
                            containsNumber = false;
                          });
                        }
                        if (val.contains(RegExp(r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'))) {
                          setState(() {
                            containsSpecialChar = true;
                          });
                        } else {
                          setState(() {
                            containsSpecialChar = false;
                          });
                        }
                        if (val.length >= 8) {
                          setState(() {
                            contains8Length = true;
                          });
                        } else {
                          setState(() {
                            contains8Length = false;
                          });
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
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$').hasMatch(val)) {
                          return 'Your password must contain at least: 1 number, 1 special character, 1 uppercase and at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: MyTextField(
                      controller: nameController,
                      hintText: 'Name',
                      obscureText: false,
                      keyboardType: TextInputType.name,
                      prefixIcon: const Icon(CupertinoIcons.person_fill),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        } else if (val.length > 16) {
                          return 'Name too long';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            !signUpRequired
                ? SizedBox(
                    width: MediaQuery.of(context).size.width / 7,
                    child: TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          MyUser myUser = MyUser.empty;
                          myUser = myUser.copyWith(
                            email: emailController.text,
                            name: nameController.text,
                          );
                          setState(() {
                            context.read<SignUpBloc>().add(
                                  SignUpRequired(myUser, passwordController.text),
                                );
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        elevation: 3.0,
                        backgroundColor: const Color.fromRGBO(91, 196, 95, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        child: Text(
                          'Sign Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
  );
}
}