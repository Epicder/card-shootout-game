import 'package:flutter/material.dart';

class PlayerCardDraft extends StatelessWidget {
  final String playerName;
  final String playerPosition;
  final int playerLevel;
  final String playerCountry;
  final String playerImage;
  final int shootingOptions;

  const PlayerCardDraft({
    required this.playerName,
    required this.playerPosition,
    required this.playerLevel,
    required this.playerCountry,
    required this.playerImage,
    required this.shootingOptions,
  });

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Container(
    width: screenWidth * 0.7, // 70% of screen width
    height: screenHeight * 0.6, // 60% of screen height
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/fondo_cartas.png'), // Fondo de la carta
      ),
      borderRadius: BorderRadius.circular(19.0),
    ),
    child: Stack(
      children: [
        // Imagen del jugador
        Positioned(
          left: screenWidth * 0.056, // 2.5% of screen width
          top: screenHeight * 0.066, // 6.5% of screen height
          child: Image.network(
            playerImage, // Aquí deberás pasar el URL de la imagen según tu lógica
            height: screenHeight * 0.40, // 30% of screen height
            fit: BoxFit.fill,
          ),
        ),
        // Nombre del jugador
        Positioned(
          top: screenHeight * 0.013, // 3% of screen height
          left: screenWidth * 0.060, // 5% of screen width
          child: Text(
            playerName.toUpperCase(),
            style: TextStyle(
              fontFamily: 'SPEED',
              fontSize: screenWidth * 0.0175, // 6% of screen width
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(255, 56, 199, 73),
              shadows: [
                Shadow(
                  color: const Color.fromARGB(255, 12, 78, 3),
                  offset: Offset(2.0, 2.0),
                  blurRadius: 2.0,
                ),
              ],
            ),
          ),
        ),
        // Nivel del jugador
        Positioned(
          bottom: screenHeight * 0.027, // 3% of screen height
          right: screenWidth * 0.070, // 8% of screen width
          child: Text(
            '$playerLevel',
            style: TextStyle(
              fontFamily: 'Black Ops One',
              fontSize: screenWidth * 0.035, // 15% of screen width
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2.5, 2.5),
                ),
              ],
            ),
          ),
        ),
        // Posición del jugador
        Positioned(
          top: screenHeight * 0.16, // 20% of screen height
          right: screenWidth * -0.15, // 5% of screen width
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.217, // 2.5% of screen width
              vertical: screenHeight * 0.092, // 0.7% of screen height
            ),
            child: Container(
            width: screenWidth * 0.076, // 13% of screen width
            height: screenHeight * 0.047, // 7% of screen height
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 56, 199, 73).withOpacity(0.7),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Text(
              playerPosition.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.015, // 4% of screen width
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        ),
        // Opciones de tiro
        Positioned(
          top: screenHeight * 0.325, // 27% of screen height
          right: screenWidth * 0.070, // 5% of screen width
          child: Container(
            width: screenWidth * 0.030, // 13% of screen width
            height: screenHeight * 0.06, // 7% of screen height
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.77),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                '$shootingOptions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.022, // 7% of screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // País
        Positioned(
          top: screenHeight * 0.105, // 6.5% of screen height
          right: screenWidth * 0.025, // 5% of screen width
          child: Image.network(
            playerCountry, // Aquí deberás pasar el URL de la bandera según tu lógica
            width: screenWidth * 0.13, // 8% of screen width
            height: screenHeight * 0.06, // 3% of screen height
          ),
        ),
      ],
    ),
  );
}
}