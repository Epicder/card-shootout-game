import 'dart:ui';
import 'dart:math'; // Importa la librería dart:math para obtener un jugador al azar

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:penalty_card_game/screens/home/draft_screen.dart';
import 'package:penalty_card_game/screens/home/mvp_screen.dart';
import 'package:penalty_card_game/player_cards/player_card_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentPlayerId = 'luis_suárez'; // ID del jugador actual

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // Restore the orientation to portrait mode when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

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


          // Contenedor de "RECORD"
          _buildRecordContainer(context),

          // Imagen del Jugador y el texto "ONE TO WATCH"
          _buildPlayerImage(),
          _buildOneToWatchText(context),

          // Botones del Menú: CPU
          _buildGameModeButton(context, '⚽ Start a new match!', const Alignment(-0.56, 0.8)),
          _buildChangePlayerButton(context, 'Change', const Alignment(0.63, 0.8)),
        ],
      ),
    );
  }

  // Widget para el fondo de imagen
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/fondo_menu.jpg',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              color: Colors.black.withOpacity(0.0),
            ),
          ),
        ],
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



  // Widget para el contenedor de "RECORD"
  Widget _buildRecordContainer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: const Alignment(-0.65, -0.4),
      child: Container(
        width: screenWidth * 0.4, // 80% of screen width
        height: screenHeight * 0.6, // 40% of screen height
        decoration: BoxDecoration(
          color: const Color(0xD60B1415),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15.0,
              color: const Color.fromRGBO(91, 196, 95, 0.7).withOpacity(0.5),
              offset: const Offset(0.0, 2.0),
              spreadRadius: 8.0,
            ),
          ],
          border: Border.all(
            color: const Color.fromARGB(255, 41, 141, 52),
            width: 3.2,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0.0, 0.0),
              child: StreamBuilder(
                stream: _getAllMatches(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("error");
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text(
                      'Play one game to see your recent matches!',
                      style: TextStyle(
                        fontFamily: 'Lekton',
                        color: Colors.white,
                        fontSize: screenWidth * 0.05, // 5% of screen width
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var match = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        int playerScore = match['playerScore'];
                        int cpuScore = match['cpuScore'];

                        // ASIGNAR TEXTO EN FUNCIÓN DE SI ES WIN O LOSE
                        String resultText = playerScore > cpuScore ? "Win" : "Lose";
                        Color resultColor = playerScore > cpuScore ? const Color(0xFF82eca5) : const Color.fromARGB(255, 197, 54, 43);

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.01, left: screenWidth * 0.01), // 1% of screen height, 1% of screen width
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$resultText: $playerScore - $cpuScore',
                                  style: TextStyle(
                                    fontFamily: 'Lekton',
                                    color: resultColor,
                                    fontSize: screenWidth * 0.038, // 3.8% of screen width
                                    letterSpacing: 3.0,
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.italic,
                                    shadows: [
                                      Shadow(
                                        color: resultColor.withOpacity(0.8), // Color del glow con opacidad
                                        blurRadius: 50.0, // Radio del blur para el glow
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: const Color.fromARGB(255, 32, 139, 55), // Color de la línea separadora
                              thickness: 0.4, // Grosor de la línea separadora
                              indent: screenWidth * 0.01, // Indentación desde la izquierda
                              endIndent: screenWidth * 0.02, // Indentación desde la derecha
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Align(
              alignment: const Alignment(-1.0, -1.43),
              child: Text(
                'RECORD',
                style: TextStyle(
                  fontFamily: 'Speedway',
                  color: const Color.fromARGB(255, 60, 214, 78),
                  shadows: [
                    Shadow(
                      color: const Color(0xFF013D09),
                      offset: Offset(screenWidth * 0.012, 1.5), // 0.6% of screen width
                    ),
                    Shadow(
                      color: const Color(0xFF41E854).withOpacity(0.5), // Verde con opacidad para el glow
                      blurRadius: 30.0, // Radio del blur para el glow
                    ),
                  ],
                  fontSize: screenWidth * 0.0515, // 5.15% of screen width
                  letterSpacing: 7.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OBTENER LA COLECCIÓN MATCHES PARA MOSTRARLA
  Stream<QuerySnapshot> _getAllMatches() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("Usuario no autenticado");
    }

    String uid = currentUser.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('matches')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Widget para la carta del jugador desde Firestore
  Widget _buildPlayerImage() {
    return Align(
      alignment: const Alignment(1.8, -0.31),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Delanteros')
            .doc(currentPlayerId) // Usar el ID del jugador actual
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var playerData = snapshot.data!.data() as Map<String, dynamic>;
          return PlayerCard(
            playerName: playerData['name'],
            playerPosition: playerData['position'],
            playerLevel: playerData['level'],
            playerCountry: playerData['country'],
            playerImage: playerData['image'],
            shootingOptions: playerData['shooting_options'],
          );
        },
      ),
    );
  }

  // Widget para el texto "ONE TO WATCH"
  Widget _buildOneToWatchText(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment(0.9, -0.1),
      child: Text(
        'ONE\nTO\nWATCH',
        style: TextStyle(
          fontFamily: 'SPORT',
          color: const Color.fromARGB(255, 56, 199, 73),
          fontSize: screenWidth * 0.035, // 6% of screen width
          letterSpacing: 2.0,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: const Color.fromARGB(255, 12, 78, 3),
              offset: Offset(-screenWidth * 0.004, 0.0), // 0.6% of screen width
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
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(91, 196, 95, 0.7).withOpacity(0.70), // El color del brillo
              spreadRadius: 5,
              blurRadius: 12,
              offset: Offset(0, 0),
            ),
          ],
          borderRadius: BorderRadius.circular(55.0), // Bordes redondeados que coinciden con el botón
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DraftScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 56, 199, 73),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 9.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(55.0),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Lekton',
              fontSize: 17.0,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el botón "Change"
  Widget _buildChangePlayerButton(BuildContext context, String text, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(91, 196, 95, 0.7).withOpacity(0.70), // El color del brillo
              spreadRadius: 5,
              blurRadius: 12,
              offset: Offset(0, 0),
            ),
          ],
          borderRadius: BorderRadius.circular(55.0), // Bordes redondeados que coinciden con el botón
        ),
        child: ElevatedButton(
          onPressed: () async {
            // Obtener un jugador al azar
            var randomPlayerId = await _getRandomPlayerId();
            setState(() {
              currentPlayerId = randomPlayerId;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 56, 199, 73),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 9.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(55.0),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Lekton',
              fontSize: 17.0,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Método para obtener un jugador al azar
  Future<String> _getRandomPlayerId() async {
    var collection = FirebaseFirestore.instance.collection('Delanteros');
    var querySnapshot = await collection.get();
    var allPlayers = querySnapshot.docs;
    var randomIndex = Random().nextInt(allPlayers.length);
    return allPlayers[randomIndex].id;
  }
}