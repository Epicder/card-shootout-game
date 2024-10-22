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
  final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            const SizedBox(height: 10),
            Container(
           padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(91, 196, 95, 0.7), // Background color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildEmailField(context),
                  const SizedBox(height: 7),
                  _buildPasswordField(context),
                  const SizedBox(height: 7),
                  _buildNameField(context),
                ],
              ),
            ),
            const SizedBox(height: 5),
            _buildSignUpButton(context),
          ],
        ),
      ),
    ),
  );
}

Widget _buildEmailField(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width / 3,
    child: Container(
      height: 35, // Set the desired height here
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
  );
}

Widget _buildPasswordField(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width / 3,
    child: Container(
      height: 35, // Set the desired height here
      child: MyTextField(
        controller: passwordController,
        hintText: 'Password',
        obscureText: obscurePassword,
        keyboardType: TextInputType.visiblePassword,
        prefixIcon: const Icon(CupertinoIcons.lock_fill),
        onChanged: (val) {
          setState(() {
            containsUpperCase = val!.contains(RegExp(r'[A-Z]'));
            containsLowerCase = val.contains(RegExp(r'[a-z]'));
            containsNumber = val.contains(RegExp(r'[0-9]'));
            containsSpecialChar = val.contains(RegExp(r'[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]'));
            contains8Length = val.length >= 8;
          });
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
  );
}

Widget _buildNameField(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width / 3,
    child: Container(
      height: 35, // Set the desired height here
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
  );
}

Widget _buildSignUpButton(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return !signUpRequired
      ? SizedBox(
          width: screenWidth * 0.14,
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
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              child: Text(
                'Sign Up',
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
      : const CircularProgressIndicator();
}
}