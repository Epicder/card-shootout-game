import 'package:flutter/material.dart';

class PlayerCardMVP extends StatelessWidget {
  final String playerName;
  final String playerPosition;
  final int playerLevel;
  final String playerCountry;
  final String playerImage;
  final int shootingOptions;


  const PlayerCardMVP({
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
      width: screenWidth * 0.27, // Ajusta el tamaño de la carta para la pantalla MVP
      height: screenHeight * 0.53, // Ajusta la altura de la carta
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
            left: screenWidth * 0.065, // Ajusta la posición horizontal
            top: screenHeight * 0.070, // Ajusta la posición vertical
            child: Image.network(
              playerImage, // URL de la imagen del jugador
              height: screenHeight * 0.44, // Tamaño de la imagen
              fit: BoxFit.fill,
            ),
          ),
          // Nombre del jugador
          Positioned(
            top: screenHeight * 0.015, // Ajusta la posición del texto
            left: screenWidth * 0.070, // Ajusta la posición del texto
            child: Text(
              playerName.toUpperCase(),
              style: TextStyle(
                fontFamily: 'SPEED',
                fontSize: screenWidth * 0.017, // Ajusta el tamaño del texto
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
            bottom: screenHeight * 0.033, // Ajusta la posición del nivel
            right: screenWidth * 0.074, // Ajusta la posición
            child: Text(
              '$playerLevel',
              style: TextStyle(
                fontFamily: 'Black Ops One',
                fontSize: screenWidth * 0.035, // Ajusta el tamaño del texto
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
            top: screenHeight * 0.32, // Ajusta la posición
            right: screenWidth * 0.068, // Ajusta la posición
            child: Container(
              width: screenWidth * 0.082, // Ajusta el tamaño del contenedor
              height: screenHeight * 0.035, // Ajusta el tamaño
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 5, 197, 28).withOpacity(1),
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Center(
                child: Text(
                  playerPosition.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: screenWidth * 0.014, // Ajusta el tamaño del texto
                  ),
                ),
              ),
            ),
          ),
          // Opciones de tiro (centrar número en un círculo con borde)
          Positioned(
            top: screenHeight * 0.19, // Ajusta según tu diseño
            right: screenWidth * 0.066, // Ajusta según tu diseño
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
                    fontSize: screenWidth * 0.024, // Ajusta el tamaño según tu diseño
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bandera del país (reducir tamaño)
          Positioned(
            top: screenHeight * 0.100, // Ajusta según tu diseño
            right: screenWidth * 0.047, // Ajusta según tu diseño
            child: Image.network(
              playerCountry, // Aquí deberás pasar el URL de la bandera según tu lógica
              width: screenWidth * 0.07, // Ajustado para reducir el ancho
              height: screenHeight * 0.035, // Ajustado para reducir la altura
            ),
          ),
        ],
      ),
    );
  }
}