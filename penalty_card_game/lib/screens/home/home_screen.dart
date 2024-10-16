import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penalty_card_game/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:penalty_card_game/screens/home/draft_screen.dart';
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
      height: 270.0, // A AJUSTAR LUEGO
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
                      fontSize: 26.0,
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
                      Color resultColor = playerScore > cpuScore ? Colors.green : Colors.red;

                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0, left: 10.0),
                        child: Text(
                          '$resultText: $playerScore - $cpuScore',
                          style: TextStyle(
                            fontFamily: 'Lekton',
                            color: resultColor,
                            fontSize: 30.0,
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
            alignment: const Alignment(0.01, -1.37),
            child: Text(
              
              'Historial de Partidas',
              style: TextStyle(
                fontFamily: 'Foldit',
                color: Colors.yellow,
                fontSize: 30.0,
                letterSpacing: 3.0,
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
            MaterialPageRoute(builder: (context) => DraftScreen()),
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
    ); 
  }  // Sección de Progreso del Jugador
}
