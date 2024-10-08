import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:penalty_card_game/screens/home/mvp_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: AppBar(
				title: const Text(
					'MAIN MENU Penalty Card Shootout!'
      ),
        
				actions: [
					IconButton(
						onPressed: () {
							context.read<SignInBloc>().add(const SignOutRequired());
						}, 
						icon: Icon(Icons.login)
					),
				],
        
			),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PenaltyGame()), // En vez de HomeScreen el mvp
            );
          },
          child: const Text('Play'),
        ),
        ),
		);
  }
}
