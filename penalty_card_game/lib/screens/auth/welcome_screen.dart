import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // necesario para bloquear la orientación
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/screens/auth/sign_in_screen.dart';
import 'package:penalty_card_game/screens/auth/sign_up_screen.dart';

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
    super.initState();

    // Fijar la orientación a horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    // al salir de la pantalla, restaurar las orientaciones predeterminadas
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Imagen de fondo que cubre toda la pantalla
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('login_screen.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.5, // posicion en pantalla
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TabBar(
                            controller: tabController,
                            unselectedLabelColor: const Color.fromARGB(255, 241, 241, 241),
                            labelColor: const Color.fromRGBO(91, 196, 95, 1),
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
                                  userRepository: context.read<AuthenticationBloc>().userRepository,
                                ),
                                child: const SignInScreen(),
                              ),
                              BlocProvider<SignUpBloc>(
                                create: (context) => SignUpBloc(
                                  userRepository: context.read<AuthenticationBloc>().userRepository,
                                ),
                                child: const SignUpScreen(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}