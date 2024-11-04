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
  String currentCollection = 'Delanteros'; // Colección actual

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
          _buildGameModeButton(context, '⚽ PLAY ', const Alignment(-0.56, 0.8)),
          _buildChangePlayerButton(context, 'CHANGE', const Alignment(0.63, 0.8)),
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
            fit: BoxFit.fill,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.8, sigmaY: 2.8),
            child: Container(
              color: Colors.black.withOpacity(0.3),
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
      alignment: const Alignment(-0.65, -0.18),
      child: Container(
        width: screenWidth * 0.4, // 80% of screen width
        height: screenHeight * 0.58, // 40% of screen height
        decoration: BoxDecoration(
          color: const Color(0xD60B1415),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15.0,
              color: const Color.fromARGB(255, 247, 229, 39).withOpacity(0.40),
              offset: const Offset(0.0, 2.0),
              spreadRadius: 3.0,
            ),
          ],
          border: Border.all(
            color: const Color.fromARGB(136, 154, 152, 17),
            width: 2,
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
                      'PLAY ONE GAME \n TO SEE \n YOUR RECENT MATCHES!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SPORT',
                        color: const Color.fromARGB(255, 255, 222, 7),
                        fontSize: screenWidth * 0.046, // 5% of screen width
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(255, 255, 255, 254),
                            offset: Offset(1, 1),
                            ),
                          ],
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
                        String resultText = playerScore > cpuScore ? "WIN" : "LOSE";
                        Color resultColor = playerScore > cpuScore ? const Color(0xFF82eca5) : const Color.fromARGB(255, 197, 54, 43);

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.01, left: screenWidth * 0.0), // 1% of screen height, 1% of screen width
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '$resultText: $playerScore - $cpuScore',
                                  style: TextStyle(
                                    fontFamily: 'SPORT',
                                    color: resultColor,
                                    fontSize: screenWidth * 0.05, // 3.8% of screen width
                                    letterSpacing: 7.0,
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.normal,
                                    shadows: [
                                      Shadow(
                                        color: resultColor.withOpacity(0.8),
                                        blurRadius: 50.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: const Color.fromARGB(255, 229, 255, 0),
                              thickness: 0.5,
                              indent: screenWidth * 0.03,
                              endIndent: screenWidth * 0.03,
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
              alignment: const Alignment(0.1, -1.69),
              child: Text(
                'RECORD',
                style: TextStyle(
                  fontFamily: 'Speedway',
                  color: const Color.fromARGB(255, 221, 204, 13),
                  shadows: [
                    Shadow(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      offset: Offset(screenWidth * 0.012, 1.5) // dont change the responsive :P
                    ),
                    Shadow(
                      color: const Color.fromARGB(255, 112, 112, 104).withOpacity(0.5), // NO LO CAMBIES DALE GAS JAJJAJA, TE DEJO LOS BOTONES CON EL BOX SHADOW NEGRO PERO DEJAME ESTO ASI
                      blurRadius: 20.0, 
                    ),
                  ],
                  fontSize: screenWidth * 0.055, // 5.15% of screen width
                  letterSpacing: 8,
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
    alignment: const Alignment(1.45, -0.18),
    child: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(currentCollection) // Usa la colección almacenada
          .doc(currentPlayerId) // Usa el ID del jugador actual
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Mostramos un indicador de carga mientras se obtienen los datos
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Si no hay datos o el documento no existe, mostramos un mensaje de error
          return Text(
            'Jugador no encontrado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          );
        }

        // Verificamos que los datos no sean null y realizamos el cast a Map<String, dynamic>
        var playerData = snapshot.data!.data() as Map<String, dynamic>?;

        if (playerData == null) {
          // Si los datos del jugador son null, mostramos un mensaje de error
          return Text(
            'Datos del jugador no disponibles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          );
        }
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
      alignment: Alignment(0.86, -0.1),
      child: Text(
        'ONE\nTO\nWATCH',
        style: TextStyle(
          fontFamily: 'SPORT',
          color: const Color.fromARGB(255, 226, 211, 0),
          fontSize: screenWidth * 0.050, // 6% of screen width
          letterSpacing: 2.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: const Color.fromARGB(255, 168, 95, 0),
              offset: Offset(-screenWidth * 0.004, 0.0), // 0.6% of screen width
            ),
            Shadow(
                      color: const Color.fromARGB(255, 247, 229, 39).withOpacity(0.63), // Verde con opacidad para el glow
                      blurRadius: 77.0, // Radio del blur para el glow
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
      alignment: const Alignment(-0.45, 0.84),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(225, 0, 0, 0).withOpacity(0.55), // El color del brillo
              spreadRadius: 3,
              blurRadius: 12,
              offset: Offset(0, 0),
            ),
          ],
         borderRadius: BorderRadius.circular(60), // Bordes redondeados que coinciden con el botón
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              createSlideRoute(DraftScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:  const Color.fromARGB(226, 130, 236, 165),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'SPORT',
              fontSize: 27.0,
              letterSpacing: 1.2,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el botón "Change"
  Widget _buildChangePlayerButton(BuildContext context, String text, Alignment alignment) {
    return Align(
      alignment: const Alignment(0.51, 0.84),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(225, 0, 0, 0).withOpacity(0.55), // El color del brillo
              spreadRadius: 3,
              blurRadius: 12,
              offset: Offset(0, 0),
            ),
          ],
          borderRadius: BorderRadius.circular(60), // Bordes redondeados que coinciden con el botón
        ),
        child: ElevatedButton(
          onPressed: () async {
            // Obtener un jugador al azar y la colección correspondiente
            var result = await _getRandomPlayer();
            setState(() {
              currentPlayerId = result['playerId'] ?? 'default_player_id'; // Proporciona un ID de jugador predeterminado si es null
              currentCollection = result['collection'] ?? 'Delanteros'; // Utiliza 'Delanteros' como colección predeterminada
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(226, 130, 236, 165),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'SPORT',
              fontSize: 20.0,
              letterSpacing: 1.3,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Método para obtener un jugador al azar de cualquier posición
  Future<Map<String, String>> _getRandomPlayer() async {
    List<String> collections = ['Delanteros', 'Defensas', 'Mediocampistas', 'Goleros'];

    // Selecciona una colección aleatoriamente
    String selectedCollection = collections[Random().nextInt(collections.length)];

    // Obtener un jugador aleatorio de la colección seleccionada
    var collection = FirebaseFirestore.instance.collection(selectedCollection);
    var querySnapshot = await collection.get();
    var allPlayers = querySnapshot.docs;

    if (allPlayers.isNotEmpty) {
      var randomIndex = Random().nextInt(allPlayers.length);
      String playerId = allPlayers[randomIndex].id; // Retorna el ID del jugador
      return {'playerId': playerId, 'collection': selectedCollection}; // Retorna el jugador y la colección
    } else {
      return {'playerId': '', 'collection': selectedCollection}; // Retorna valores vacíos si no hay jugadores
    }
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