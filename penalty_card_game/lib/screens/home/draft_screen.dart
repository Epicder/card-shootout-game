import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:penalty_card_game/player_cards/player_card_draft.dart';
import 'package:penalty_card_game/screens/home/mvp_screen.dart';
import 'package:user_repository/user_repository.dart';


class DraftScreenApp extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Penalty Shootout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DraftScreen(),
    );
  }
}

class DraftScreen extends StatefulWidget {
  @override
  _DraftScreenState createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  MyUser? currentUser;

  @override
  void initState() {
    super.initState();
    // obtener el UserID del usuario autenticado
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        fetchUserData(user.uid); // fetchear la data del usuario para conseguir su nombre, filtrando por user id
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).popUntil((route) {
        if (!route.isFirst) {
          _clearDraftCollection();
        }
        return true;
      });
    });
  }

  Future<void> fetchUserData(String userId) async {
    // consulta a firestore
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (docSnapshot.exists) {
      final userData = docSnapshot.data();
      setState(() {
        currentUser = MyUser.fromEntity(MyUserEntity.fromDocument(userData!));
      });
    }
  }

  @override
  void dispose() {
    _clearDraftCollection();
    super.dispose();
  }

  Future<void> _clearDraftCollection() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // referencia al documento del usuario actual
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      // obtener la colección "my_draft"
      CollectionReference draftCollection = userRef.collection('my_draft');
      // obtener todos los documentos en la colección
      QuerySnapshot draftSnapshot = await draftCollection.get();
      // borrar cada documento
      for (DocumentSnapshot doc in draftSnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
return PopScope(
      child: Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          // Texto "TEAM DRAFT"
          Align(
            alignment: AlignmentDirectional(-0.92, -0.8),
            child: Text(
              'TEAM\n  DRAFT',
              style: TextStyle(
                fontFamily: 'Speedway',
                fontSize: 28.0,
                color: const Color.fromARGB(255, 221, 204, 13),
                  shadows: [
                    Shadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8), // Verde con opacidad para el glow
                      offset: Offset( 2.012, 2.5), // 0.6% of screen width
                    ),
                    Shadow(
                      color: const Color.fromARGB(255, 255, 235, 15).withOpacity(0.6), // Verde con opacidad para el glow
                      blurRadius: 20.0, // Radio del blur para el glow
                    ),
                  ],
                fontWeight: FontWeight.w600,
                letterSpacing: 8.0,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.92, -0.08),
            child: Container(
              width: 120.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: const Color.fromARGB(123, 242, 242, 242),
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 255, 255), // Color del borde
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Espaciado interno
              child: Text(
                "${currentUser?.name ?? 'Your'} FC",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Rubik Wet Paint',
                  color:  Color.fromARGB(255, 255, 255, 255), // Color del texto
                  fontSize: 15.0, // Tamaño del texto
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.65, -0.09),
            child: GestureDetector(
            onTap: () async {
              bool isDraftComplete = await _checkDraftCompletion();
              if (isDraftComplete) {
                Navigator.push(
              context,
              createSlideRoute(PenaltyGame()), 
                );
              } else {
        _showIncompleteDraftPopup(context);
              }
            },
              child: Container(
                width: 82.0,
                height: 82.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 104, 184, 121),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    width: 3.0,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 65.0,
                ),
              ),
            ),
          ),

          // Botones de los jugadores (lugares para seleccionar los jugadores)
          ..._buildPlayerSlots(),
        ],
      ),
    ),
   );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/fondo_draft.jpg',
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

// ------------------ estado de selección y jugadores seleccionados (COMPROBACION DE NO REPETIR JUGADOR) ------------------ //
Set<String> selectedPlayers = {};
Map<String, Map<int, bool>> playerSelectedStatus = {
  'Delanteros': {1: false, 2: false, 3: false},
  'Mediocampistas': {1: false, 2: false},
  'Defensas': {1: false, 2: false},
  'Goleros': {1: false},
};

// ------------------ mapas de jugadores seleccionados para cada tipo (para reemplazo de botón) ------------------ //
Map<String, ValueNotifier<Map<int, Map<String, dynamic>>>> selectedCards = {
  'Delanteros': ValueNotifier({}),
  'Mediocampistas': ValueNotifier({}),
  'Defensas': ValueNotifier({}),
  'Goleros': ValueNotifier({}),
};

List<Widget> _buildPlayerSlots() {
  return [
    _playerSlotButton('Delanteros', -0.35, -0.7, 1),
    _playerSlotButton('Delanteros', 0.35, -0.7, 2),
    _playerSlotButton('Delanteros', 0, -0.8, 3),
    _playerSlotButton('Mediocampistas', -0.15, -0.1, 1),
    _playerSlotButton('Mediocampistas', 0.15, -0.1, 2),
    _playerSlotButton('Defensas', -0.35, 0.5, 1),
    _playerSlotButton('Defensas', 0.355, 0.5, 2),
    _playerSlotButton('Goleros', 0.001, 0.85, 1),
  ];
}

Widget _playerSlotButton(String position, double x, double y, int buttonIndex) {
  return Align(
    alignment: Alignment(x, y),
    child: ValueListenableBuilder<Map<int, Map<String, dynamic>>>(
      valueListenable: selectedCards[position]!,
      builder: (context, value, child) {
        return value.containsKey(buttonIndex)
            ? Image.network(
                value[buttonIndex]!['image'],
                width: 52.0,
                height: 85.0,
                fit: BoxFit.cover,
              )
            : ElevatedButton(
                onPressed: () {
                  if (!playerSelectedStatus[position]![buttonIndex]!) {
                    showPlayersForButton(context, position, buttonIndex);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xD468B879),
                  padding: EdgeInsets.zero,
                  fixedSize: Size(52.0, 85.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Lottie.asset(
                  'assets/animations/plus.json',
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
              ),
              );
      },
    ),
  );
}

void showPlayersForButton(BuildContext context, String position, int buttonIndex) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.3,
        maxChildSize: 1,
        builder: (BuildContext context, ScrollController scrollController) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(76, 2, 78, 32).withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(0, 255, 255, 255).withOpacity(0.0),
                    spreadRadius: 5.0,
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: Colors.yellow, 
                    width: 3.0, 
                  ),
                  left: BorderSide(
                    color: Colors.yellow,
                    width: 3.0, 
                  ),
                  right: BorderSide(
                    color: Colors.yellow, 
                    width: 3.0, 
                  ),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(position).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var playerDocs = snapshot.data!.docs;

                  return GridView.builder(
                    controller: scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: playerDocs.length,
                    itemBuilder: (context, index) {
                      var playerData = playerDocs[index].data() as Map<String, dynamic>;
                      String playerId = playerDocs[index].id;
                      bool isSelected = selectedPlayers.contains(playerId);

                      return GestureDetector(
                        onTap: () {
                          if (isSelected) return;

                          // Marcar el botón como seleccionado
                          playerSelectedStatus[position]![buttonIndex] = true;
                          selectedPlayers.add(playerId);

                          // Agregar jugador a la selección
                          _addToDraft(position, buttonIndex, playerData, playerId);

                          Navigator.of(context).pop();
                        },
                        child: Opacity(
                          opacity: isSelected ? 0.5 : 1.0,
                          child: PlayerCardDraft(
                            playerName: playerData['name'],
                            playerPosition: playerData['position'],
                            playerLevel: playerData['level'],
                            playerCountry: playerData['country'],
                            playerImage: playerData['image'],
                            shootingOptions: playerData['shooting_options'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}
// ------------------ Funciones de selección de jugadores ------------------ //
void _addToDraft(String position, int buttonIndex, Map<String, dynamic> playerData, String playerId) async {
  selectedCards[position]!.value = {
    ...selectedCards[position]!.value,
    buttonIndex: playerData,
  };
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // referencia al documento del usuario actual
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    // añadir el jugador a la subcolección "my_draft" en el documento del usuario
    await userRef.collection('my_draft').doc(playerId).set({
      'name': playerData['name'],
      'position': playerData['position'],
      'level': playerData['level'],
      'country': playerData['country'],
      'image': playerData['image'],
      'shooting_options': playerData['shooting_options'],
    });
    
    // debug
    print('${playerData['name']} ha sido añadido a my_draft.');
  }
}

Future<bool> _checkDraftCompletion() async {
  // usuario actual
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    // referencia al documento del usuario actual
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    // obtener la cantidad de documentos(o sea jugadores guardados) en la subcolección "my_draft"
    QuerySnapshot draftSnapshot = await userRef.collection('my_draft').get();

    // si hay 8 jugadores
    if (draftSnapshot.size == 8) {
      return true; // El draft está completo
    }
  }

  return false; // El draft no está completo
}

void _showIncompleteDraftPopup(BuildContext context) { 
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Añade el desenfoque aquí
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(255, 55, 196, 71).withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.white, width: 2.0),
          ),
          title: Text(
            "Incomplete Draft",
            style: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.white,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          content: Text(
            "Complete your draft to Play!",
            style: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.white,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.white,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

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

