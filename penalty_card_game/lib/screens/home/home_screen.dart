import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:penalty_card_game/screens/home/draft_screen.dart';
import 'package:penalty_card_game/screens/home/mvp_screen.dart';
import 'package:penalty_card_game/player_cards/player_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

          // Título principal "CARD SHOOTOUT"
          _buildTitleText(),

          // Contenedor de "RECORD"
          _buildRecordContainer(context),

          // Imagen del Jugador y el texto "ONE TO WATCH"
          _buildPlayerImage(),
          _buildOneToWatchText(context),

          // Botones del Menú: CPU
          _buildGameModeButton(context, 'Play!', const Alignment(0.0, 0.8)),

        ],
      ),
    );
  }
  

  // Widget para el fondo de imagen
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.8,
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
          color: const Color.fromARGB(168, 146, 151, 151),
          width: 0.5,
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
                  // Mostrar la lista de resultados
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var match = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      int playerScore = match['playerScore'];
                      int cpuScore = match['cpuScore'];

                      // ASIGNAR TEXTO EN FUNCIÓN DE SI ES WIN O LOSE
                      String resultText = playerScore > cpuScore ? "Win" : "Lose";
                      Color resultColor = playerScore > cpuScore ? Colors.green : const Color.fromARGB(255, 197, 54, 43);

                      return Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01, left: screenWidth * 0.03), // 2% of screen height, 3% of screen width
                        child: Text(
                          '$resultText: $playerScore - $cpuScore',
                          style: TextStyle(
                            fontFamily: 'Lekton',
                            color: resultColor,
                            fontSize: screenWidth * 0.038, // 6% of screen width
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Align(
            alignment: const Alignment(-1.0, -1.37),
            child: Text(
              'RECORD',
              style: TextStyle(
                fontFamily: 'Speed',
                color: Colors.yellow,
                fontSize: screenWidth * 0.055, // 7% of screen width
                letterSpacing: 2.5,
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
          .doc('luis_suárez') // Cambia el ID al del jugador que quieras mostrar
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
    alignment: Alignment(0.94, -0.1),
    child: Text(
      'ONE\nTO\nWATCH',
      style: TextStyle(
        fontFamily: 'Fugaz One',
        color: const Color(0xFFFFE73D),
        fontSize: screenWidth * 0.025, // 6% of screen width
        letterSpacing: 2.0,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            color: const Color(0xC0EE8B60),
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
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DraftScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 48, 139, 80),
          foregroundColor: const Color.fromARGB(255, 213, 239, 82),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: BorderSide(
              color: const Color.fromARGB(255, 71, 230, 140),
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Foldit',
            fontSize: 18.0,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ); 
  }  // Sección de Progreso del Jugador
}
