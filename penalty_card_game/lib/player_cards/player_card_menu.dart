import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final String playerName;
  final String playerPosition;
  final int playerLevel;
  final String playerCountry;
  final String playerImage;
  final int shootingOptions;

  const PlayerCard({
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
    width: screenWidth * 0.68, // 70% of screen width
    height: screenHeight * 0.58, // 60% of screen height
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
          left: screenWidth * 0.260, // 2.5% of screen width
          top: screenHeight * 0.09, // 6.5% of screen height
          child: Image.network(
            playerImage, // Aquí deberás pasar el URL de la imagen según tu lógica
            height: screenHeight * 0.44, // 30% of screen height
            fit: BoxFit.fill,
          ),
        ),
        // Nombre del jugador
        Positioned(
          top: screenHeight * 0.013, // 3% of screen height
          left: screenWidth * 0.269, // 5% of screen width
          child: Text(
            playerName.toUpperCase(),
            style: TextStyle(
              fontFamily: 'SPEED',
              fontSize: screenWidth * 0.0160, // 6% of screen width
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(255, 248, 248, 248),
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
          bottom: screenHeight * 0.031, // 3% of screen height
          right: screenWidth * 0.272, // 8% of screen width
          child: Text(
            '$playerLevel',
            style: TextStyle(
              fontFamily: 'Black Ops One',
              fontSize: screenWidth * 0.035, // 15% of screen width
              color: const Color.fromARGB(255, 251, 253, 253),
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
          top: screenHeight * 0.25, // 28% of screen height
          right: screenWidth * 0.045, // 4.4% of screen width
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.217, // Ajusta según tu diseño
              vertical: screenHeight * 0.092, // Ajusta según tu diseño
            ),
            child: Container(
              width: screenWidth * 0.086, // 8.6% of screen width
              height: screenHeight * 0.047, // Ajusta el tamaño según tu diseño
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 5, 197, 28).withOpacity(1),
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Center( // Asegura que el texto esté centrado dentro del contenedor
                child: Text(
                  playerPosition.toUpperCase(),
                  textAlign: TextAlign.center, // Centra el texto horizontalmente
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: screenWidth * 0.014, // Ajusta el tamaño según tu diseño
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Opciones de tiro (centrar número en un círculo con borde)
        Positioned(
          top: screenHeight * 0.20, // Ajusta según tu diseño
          right: screenWidth * 0.263, // Ajusta según tu diseño
          child: Container(
            width: screenWidth * 0.035, // Ajusta el ancho para que sea más pequeño si es necesario
            height: screenWidth * 0.035, // Ajusta la altura para que sea igual al ancho, formando un círculo
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle, // Asegura que sea un círculo perfecto
              border: Border.all( // Añadir un borde
                color: Colors.white,
                width: 1.4,
              ),
            ),
            child: Center(
              child: Text(
                '$shootingOptions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.020, // Ajusta el tamaño según tu diseño
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Bandera del país (reducir tamaño)
        Positioned(
          top: screenHeight * 0.10, // Ajusta según tu diseño
          right: screenWidth * 0.243, // Ajusta según tu diseño
          child: Image.network(
            playerCountry, // Aquí deberás pasar el URL de la bandera según tu lógica
            width: screenWidth * 0.08, // Ajustado para reducir el ancho
            height: screenHeight * 0.045, // Ajustado para reducir la altura
          ),
        ),
      ],
    ),
  );
}
}