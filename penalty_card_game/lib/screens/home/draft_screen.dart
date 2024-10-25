import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          // Texto "TEAM DRAFT"
          Align(
            alignment: AlignmentDirectional(1, -0.7),
            child: Text(
              'TEAM \n    DRAFT',
              style: TextStyle(
                fontFamily: 'Speedway',
                fontSize: 33.0,
                color: const Color.fromARGB(255, 221, 204, 13),
                  shadows: [
                    Shadow(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      offset: Offset( 2.012, 2.5), // 0.6% of screen width
                    ),
                    Shadow(
                      color: const Color.fromARGB(255, 247, 229, 39).withOpacity(0.66), // Verde con opacidad para el glow
                      blurRadius: 30.0, // Radio del blur para el glow
                    ),
                  ],
                fontWeight: FontWeight.w900,
                letterSpacing: 5.0,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.97, 0.09),
            child: Container(
              width: 120.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 9, 207, 68),
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(
                  color: const Color.fromARGB(255, 14, 136, 14), // Color del borde
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
                style: TextStyle(
                  fontFamily: 'Denk One',
                  color:  Color.fromARGB(255, 255, 255, 255), // Color del texto
                  fontSize: 13.0, // Tamaño del texto
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.66, 0.1),
            child: GestureDetector(
            onTap: () async {
              bool isDraftComplete = await _checkDraftCompletion();
              if (isDraftComplete) {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PenaltyGame()), 
                );
              } else {
        _showIncompleteDraftPopup(context);
              }
            },
              child: Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 56, 199, 73),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: const Color.fromARGB(255, 41, 141, 52),
                    width: 3.0,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40.0,
                ),
              ),
            ),
          ),

          // Botones de los jugadores (lugares para seleccionar los jugadores)
          ..._buildPlayerSlots(),
        ],
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

  // Método para construir los botones de los espacios de jugadores
  List<Widget> _buildPlayerSlots() {
    return [
    _playerSlotButtonDEL(-0.42, -0.7, 1),
    _playerSlotButtonDEL(0.28, -0.7, 2),
    _playerSlotButtonDEL(-0.07, -0.8, 3),
    _playerSlotButtonMID(-0.27, -0.1, 1),
    _playerSlotButtonMID(0.13, -0.1, 2),
    _playerSlotButtonDEF(-0.42, 0.5, 1),
    _playerSlotButtonDEF(0.28, 0.5, 2),
    _playerSlotButtonGK(-0.07, 0.85, 1),
  ];
  }

Widget _playerSlotButtonDEF(double x, double y, int buttonIndex) {
  return Align(
    alignment: Alignment(x, y),
    child: ElevatedButton(
      onPressed: () {
        if (buttonIndex == 1 && !_playerSelected_DEF_1) {
          showDefensasForButton(context, 1);
        } else if (buttonIndex == 2 && !_playerSelected_DEF_2) {
          showDefensasForButton(context, 2);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xD468B879),
        padding: EdgeInsets.zero,
        fixedSize: Size(12.0, 85.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        '+',
        style: TextStyle(
          fontFamily: 'Azeret Mono',
          fontSize: 40.0,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _playerSlotButtonGK(double x, double y, int buttonIndex) {
  return Align(
    alignment: Alignment(x, y),
    child: ElevatedButton(
      onPressed: () {
        if (buttonIndex == 1 && !_playerSelected_GK_1) {
          showGolerosForButton(context, 1);
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
      child: Text(
        '+',
        style: TextStyle(
          fontFamily: 'Azeret Mono',
          fontSize: 40.0,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
            ),
          ],
        ),
      ),
    ),
  );
  }


////////////////////////// MOSTRAR DELANTEROS /////////////////////////
bool _playerSelected_DEL_1 = false;
bool _playerSelected_DEL_2 = false;
bool _playerSelected_DEL_3 = false;

Set<String> selectedPlayers = {};

void showDelanterosForButton(BuildContext context, int buttonIndex) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Añade el desenfoque aquí
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(255, 49, 173, 63).withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.white, width: 2.0),
          ),
          content: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 47, 168, 61).withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Delanteros').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var playerDocs = snapshot.data!.docs;

                return GridView.builder(
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
                        if (isSelected) {
                          return;
                        }

                        if (buttonIndex == 1 && !_playerSelected_DEL_1) {
                          _playerSelected_DEL_1 = true;
                          _addToDraft(playerId, playerData, context);
                        } else if (buttonIndex == 2 && !_playerSelected_DEL_2) {
                          _playerSelected_DEL_2 = true;
                          _addToDraft(playerId, playerData, context);
                        } else if (buttonIndex == 3 && !_playerSelected_DEL_3) {
                          _playerSelected_DEL_3 = true;
                          _addToDraft(playerId, playerData, context);
                        }

                        // agregar el jugador al set
                        selectedPlayers.add(playerId);
                      },
                      child: Opacity(
                        opacity: isSelected ? 0.5 : 1.0, // Si está seleccionado, hacer la carta semitransparente
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
        ),
      );
    },
  );
}
///////////////////////////////////////////////// /////////////////////////

////////////////////////// MOSTRAR MEDIOCAMPISTAS /////////////////////////
bool _playerSelected_MID_1 = false;
bool _playerSelected_MID_2 = false;

Set<String> selectedPlayers_MID = {};

void showMediocampistasForButton(BuildContext context, int buttonIndex) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Añade el desenfoque aquí
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(255, 49, 173, 63).withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.white, width: 2.0),
          ),
          content: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 47, 168, 61).withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Mediocampistas').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var playerDocs = snapshot.data!.docs;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: playerDocs.length,
                  itemBuilder: (context, index) {
                    var playerData = playerDocs[index].data() as Map<String, dynamic>;
                    String playerId = playerDocs[index].id;

                    // Verificar si el jugador ya ha sido seleccionado
                    bool isSelected = selectedPlayers.contains(playerId);

                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          return; 
                        }

                        // Verifica cuál botón de la pantalla llamó a la funcion
                        if (buttonIndex == 1 && !_playerSelected_MID_1) {
                          _playerSelected_MID_1 = true;
                          _addToDraft(playerId, playerData, context);
                        } else if (buttonIndex == 2 && !_playerSelected_MID_2) {
                          _playerSelected_MID_2 = true;
                          _addToDraft(playerId, playerData, context);
                        }

                        // Agregar el jugador al set
                        selectedPlayers.add(playerId);
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
        ),
      );
    },
  );
}
//////////////////////////////////////////////////////////////////////////

bool _playerSelected_DEF_1 = false;
bool _playerSelected_DEF_2 = false;

Set<String> selectedPlayers_DEF = {};

void showDefensasForButton(BuildContext context, int buttonIndex) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Añade el desenfoque aquí
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(255, 49, 173, 63).withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.white, width: 2.0),
          ),
          content: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 47, 168, 61).withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Defensas').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var playerDocs = snapshot.data!.docs;

                return GridView.builder(
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
                        if (isSelected) {
                          return;
                        }

                        // Verifica cuál botón ha llamado la funcion
                        if (buttonIndex == 1 && !_playerSelected_DEF_1) {
                          _playerSelected_DEF_1 = true;
                          _addToDraft(playerId, playerData, context);
                        } else if (buttonIndex == 2 && !_playerSelected_DEF_2) {
                          _playerSelected_DEF_2 = true;
                          _addToDraft(playerId, playerData, context);
                        }

                        // Agregar el jugador al set
                        selectedPlayers.add(playerId);
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
        ),
      );
    },
  );
}
//////////////////////////////////////////////////////////////////////////

///////////////////////////// MOSTRAR GOLEROS ////////////////////////////
bool _playerSelected_GK_1 = false;

Set<String> selectedPlayers_GK = {};

void showGolerosForButton(BuildContext context, int buttonIndex) {

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Añade el desenfoque aquí
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(255, 49, 173, 63).withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            side: BorderSide(color: Colors.white, width: 2.0),
          ),
          content: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 47, 168, 61).withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Goleros').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var playerDocs = snapshot.data!.docs;

                return GridView.builder(
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
                        if (isSelected) {
                          return; 
                        }

                        // Verifica cuál botón ha llamado la funcion
                        if (buttonIndex == 1 && !_playerSelected_GK_1) {
                          _playerSelected_GK_1 = true;
                          _addToDraft(playerId, playerData, context);
                        }

                        selectedPlayers.add(playerId);
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
        ),
      );
    },
  );
}
//////////////////////////////////////////////////////////////////////////


//////////////////////// ADD TO DRAFT COLLECTION USER & other FUNCTIONS///
void _addToDraft(String playerId, Map<String, dynamic> playerData, BuildContext context) async {
  // usuario actual
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

     Navigator.pop(context);

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

// POP UP PARA CUANDO EL DRAFT ESTÁ INCOMPLETO
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


//////////////////////// ADD TO DRAFT COLLECTION USER/////////////////////////////////////

Widget _playerSlotButtonDEL(double x, double y, int buttonIndex) {
  return Align(
    alignment: Alignment(x, y),
    child: ElevatedButton(
      onPressed: () {
        // Abrir diálogo de selección solo si no se ha seleccionado un delantero para ese botón
        if (buttonIndex == 1 && !_playerSelected_DEL_1) {
          showDelanterosForButton(context, 1);
        } else if (buttonIndex == 2 && !_playerSelected_DEL_2) {
          showDelanterosForButton(context, 2);
        } else if (buttonIndex == 3 && !_playerSelected_DEL_3) {
          showDelanterosForButton(context, 3);
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
      child: Text(
        '+',
        style: TextStyle(
          fontFamily: 'Azeret Mono',
          fontSize: 40.0,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
            ),
          ],
        ),
      ),
    ),
  );
}

  ///////////////////////////////DELANTEROS/////////////////////////////

  //////////////////////////////MEDIOCAMPISTAS//////////////////////////

  Widget _playerSlotButtonMID(double x, double y, int buttonIndex) {
  return Align(
    alignment: Alignment(x, y),
    child: ElevatedButton(
      onPressed: () {
        // Abrir diálogo de selección solo si no se ha seleccionado un delantero para ese botón
        if (buttonIndex == 1 && !_playerSelected_MID_1) {
          showMediocampistasForButton(context, 1);
        } else if (buttonIndex == 2 && !_playerSelected_MID_2) {
          showMediocampistasForButton(context, 2);
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
      child: Text(
        '+',
        style: TextStyle(
          fontFamily: 'Azeret Mono',
          fontSize: 40.0,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black54,
              offset: Offset(2.0, 2.0),
              blurRadius: 2.0,
            ),
          ],
        ),
      ),
    ),
  );
  }
}
////////////////////////// MEDIOCAMPISTAS /////////////////////////

////////////////////////// DEFENSAS ///////////////////////////////


  void showAllGK(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Goleros').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var playerDocs = snapshot.data!.docs;
              
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: playerDocs.length,
                itemBuilder: (context, index) {
                  var playerData = playerDocs[index].data() as Map<String, dynamic>;

                  return PlayerCardDraft(
                    playerName: playerData['name'],
                    playerPosition: playerData['position'],
                    playerLevel: playerData['level'],
                    playerCountry: playerData['country'],
                    playerImage: playerData['image'],
                    shootingOptions: playerData['shooting_options'],
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}
