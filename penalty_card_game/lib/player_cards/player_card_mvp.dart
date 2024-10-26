import 'package:flutter/material.dart';

class PlayerCardMVP extends StatelessWidget {
  final String playerName;
  final String playerPosition;
  final int playerLevel;
  final String playerImage;

  const PlayerCardMVP({
    Key? key,
    required this.playerName,
    required this.playerPosition,
    required this.playerLevel,
    required this.playerImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Tamaño de la carta
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            playerImage,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          Text(
            playerName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(playerPosition),
          Text('Nivel: $playerLevel'),
        ],
      ),
    );
  }
}