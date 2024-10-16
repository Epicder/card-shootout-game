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
    return Container(
      width: 265.0,
      height: 395.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/fondo_cartas.png'), // Fondo de la carta
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          // Imagen del jugador
          Positioned(
            left: 10,
            top: 50,
            child: Image.network(
              playerImage,
              width: 131.0,
              height: 233.0,
              fit: BoxFit.fill,
            ),
          ),
          // Nombre del jugador
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              playerName.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Spectral SC',
                fontSize: 22.0,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.grey,
                    offset: Offset(2.0, 2.0),
                    blurRadius: 2.0,
                  ),
                ],
              ),
            ),
          ),
          // Nivel del jugador
          Positioned(
            bottom: 20,
            right: 20,
            child: Text(
              '$playerLevel',
              style: TextStyle(
                fontFamily: 'Black Ops One',
                fontSize: 55.0,
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
            top: 150,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                playerPosition.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          // Opciones de tiro
          Positioned(
            top: 200,
            right: 20,
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Text(
                  '$shootingOptions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // País
          Positioned(
            top: 50,
            right: 20,
            child: Image.network(
              playerCountry, // Aquí deberás pasar el URL de la bandera según tu lógica
              width: 30.0,
              height: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
