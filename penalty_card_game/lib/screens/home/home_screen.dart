import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:penalty_card_game/screens/home/mvp_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 59, 59), // Fondo oscuro para resaltar los elementos
      body: Stack(
        children: [
          // Fondo de campo de fútbol
          _buildBackgroundImage(),

          // Botón de cuenta del usuario
          _buildAccountButton(),

          // Título principal "CARD SHOOTOUT"
          _buildTitleText(),

          // Contenedor de "RECORD"
          _buildRecordContainer(),

          // Imagen del Jugador y el texto "ONE TO WATCH"
          _buildPlayerImage(),
          _buildOneToWatchText(),

          // Botones del Menú: CPU, ONLINE, FRIEND
          _buildGameModeButton(context, 'CPU', const Alignment(-0.53, 0.8)),
          _buildGameModeButton(context, 'ONLINE', const Alignment(0.0, 0.8)),
          _buildGameModeButton(context, 'FRIEND', const Alignment(0.61, 0.8)),
        ],
      ),
    );
  }

  // Widget para el fondo de imagen
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.3, // Ajusta la opacidad para que el fondo sea más tenue
        child: Image.asset(
          'assets/fondo_menu.jpg', // Asegúrate de que esta ruta sea correcta
          fit: BoxFit.cover, // La imagen cubrirá toda la pantalla
        ),
      ),
    );
  }

  // Widget para el botón de cuenta de usuario
  Widget _buildAccountButton() {
    return Align(
      alignment: const AlignmentDirectional(0.98, -0.98),
      child: IconButton(
        iconSize: 40.0,
        icon: const Icon(
          Icons.account_circle,
          color: Colors.white,
        ),
        onPressed: () {
          print('Account button pressed');
        },
      ),
    );
  }

  // Widget para el texto "CARD SHOOTOUT"
  Widget _buildTitleText() {
    return Align(
      alignment: const AlignmentDirectional(-0.95, -0.93),
      child: Text(
        'CARD SHOOTOUT',
        style: TextStyle(
          fontFamily: 'Fugaz One',
          fontSize: 10.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: const Offset(5.0, 5.0),
              blurRadius: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  // Widget para el contenedor de "RECORD"
  Widget _buildRecordContainer() {
    return Align(
      alignment: const Alignment(-0.65, -0.4),
      child: Container(
        width: 352.0,
        height: 194.0,
        decoration: BoxDecoration(
          color: const Color(0xD60B1415),
          boxShadow: [
            BoxShadow(
              blurRadius: 15.0,
              color: const Color.fromARGB(252, 63, 139, 143).withOpacity(0.5),
              offset: const Offset(0.0, 2.0),
              spreadRadius: 8.0,
            ),
          ],
          border: Border.all(
            color: const Color.fromARGB(168, 146, 151, 151),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0.0, 0.5),
              child: Text(
                '5 - 1',
                style: TextStyle(
                  fontFamily: 'Lekton',
                  color: Colors.white,
                  fontSize: 70.0,
                  letterSpacing: 10.0,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                      color: Colors.red,
                      offset: const Offset(3.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.01, -0.89),
              child: Text(
                'RECORD',
                style: TextStyle(
                  fontFamily: 'Foldit',
                  color: Colors.yellow,
                  fontSize: 40.0,
                  letterSpacing: 5.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la imagen del jugador
  Widget _buildPlayerImage() {
    return Align(
      alignment: const Alignment(0.5, -0.31),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: Image.asset(
          'assets/cristiano.jpg',
          width: 121.0,
          height: 175.0,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  // Widget para el texto "ONE TO WATCH"
  Widget _buildOneToWatchText() {
    return Align(
      alignment: const Alignment(0.87, -0.1),
      child: Text(
        'ONE\nTO\nWATCH',
        style: TextStyle(
          fontFamily: 'Fugaz One',
          color: const Color(0xFFFFE73D),
          fontSize: 25.0,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: const Color(0xC0EE8B60),
              offset: const Offset(-2.5, 0.0),
            ),
          ],
          height: 1.8,
        ),
      ),
    );
  }

  // Widget para los botones del menú
  Widget _buildGameModeButton(BuildContext context, String text, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PenaltyGame()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 38, 45, 52),
          foregroundColor: const Color.fromARGB(255, 255, 230, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: BorderSide(
              color: const Color.fromARGB(255, 88, 197, 255),
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Foldit',
            fontSize: 20.0,
            letterSpacing: 3.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

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
