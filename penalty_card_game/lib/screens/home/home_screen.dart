import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: AppBar(
				title: const Text(
					'Welcome, you are In !'
				),
				actions: [
					IconButton(
						onPressed: () {
							//context.read<SignInBloc>().add(const SignOutRequired());
						}, 
						icon: Icon(Icons.login)
					)
				],
			),
		);
  }
}