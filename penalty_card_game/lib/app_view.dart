import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:penalty_card_game/screens/auth/welcome_screen.dart';
import 'package:penalty_card_game/screens/home/home_screen.dart';
import 'package:penalty_card_game/screens/home/mvp_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Firebase Auth',
    home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state.status == AuthenticationStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              createSlideRoute(const HomeScreen()),
            );
          });
          // Muestra un widget vacío mientras se realiza la transición
          return const SizedBox(); // Puedes mostrar un indicador de carga si lo prefieres
        } else {
          return const WelcomeScreen();
        }
      },
    ),
  );
}
    //----------------------Animacion slide----------------------------------------------------------
  Route createSlideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(2.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 740),
  );
}
}