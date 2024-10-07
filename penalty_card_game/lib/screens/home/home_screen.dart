import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/blocs/sign_in_bloc/sign_in_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro para resaltar los elementos
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('RIVALS SEASON 1', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellow)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: const Text('HERNAN F.C.', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.yellow,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo de campo de fútbol
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/fondo_menu.jpg', // Imagen del fondo de tu menú
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Sección de Progreso del Jugador
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Rank II - Progress',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellow),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Climb the divisions and earn weekly rewards.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Sección de Carta del Jugador
          Positioned(
            top: 120,
            right: 30,
            child: Container(
              width: 150,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/cristiano.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Botones de Opciones de Juego
          Positioned(
            bottom: 100,
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _gameModeButton('CPU', Colors.red, context),
                _gameModeButton('Online', Colors.blue, context),
                _gameModeButton('Friendlies', Colors.green, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper para los botones de opciones de juego
  Widget _gameModeButton(String title, Color color, BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Reemplaza 'primary' por 'backgroundColor'
        foregroundColor: Colors.white, // Reemplaza 'onPrimary' por 'foregroundColor'
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),      ),
      onPressed: () {
        // Acción del botón
      },
      child: Text(title),
    );
  }
}
