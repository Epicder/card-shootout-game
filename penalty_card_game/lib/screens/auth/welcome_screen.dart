import 'dart:ui';

import 'package:penalty_card_game/screens/auth/sign_in_screen.dart';
import 'package:penalty_card_game/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/sign_in_bloc/sign_in_bloc.dart';
import '../../blocs/sign_up_bloc/sign_up_bloc.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
	late TabController tabController;

	@override
  void initState() {
    tabController = TabController(
			initialIndex: 0,
			length: 2, 
			vsync: this
		);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
			backgroundColor: const Color.fromARGB(255, 66, 148, 86),
			body: SingleChildScrollView(
				child: SizedBox(
					height: MediaQuery.of(context).size.height,
					child: Stack(
						children: [
							Align(
								alignment: Alignment.bottomCenter,
								child: SizedBox(
									height: MediaQuery.of(context).size.height / 1.8,
									child: Column(
										children: [
											Padding(
												padding: const EdgeInsets.symmetric(horizontal: 50.0),
												child: TabBar(
													controller: tabController,
													unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
													labelColor: Theme.of(context).colorScheme.onSurface,
													tabs: const [
														Padding(
															padding: EdgeInsets.all(12.0),
															child: Text(
																'Sign In',
																style: TextStyle(
																	fontSize: 20,
																),
															),
														),
														Padding(
															padding: EdgeInsets.all(12.0),
															child: Text(
																'Sign Up',
																style: TextStyle(
																	fontSize: 20,
																),
															),
														),
													],
												),
											),
											Expanded(
												child: TabBarView(
													controller: tabController,
													children: [
														BlocProvider<SignInBloc>(
															create: (context) => SignInBloc(
																userRepository: context.read<AuthenticationBloc>().userRepository
															),
															child: const SignInScreen(),
														),
														BlocProvider<SignUpBloc>(
															create: (context) => SignUpBloc(
																userRepository: context.read<AuthenticationBloc>().userRepository
															),
															child: const SignUpScreen(),
														),
													],
												)
											)
										],
									),
								),
							)
						],
					),
				),
			),
		);
  }
}