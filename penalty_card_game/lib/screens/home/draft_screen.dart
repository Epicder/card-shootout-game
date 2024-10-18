import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:penalty_card_game/player_cards/player_card.dart';
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
          // Fondo del draft
          Positioned.fill(
            child: Opacity(
              opacity: 0.9, // Ajusta la opacidad para que coincida con el diseño
              child: Image.asset(
                'fondo_draft.jpg', // Ruta de la imagen del fondo
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Texto "TEAM DRAFT"
          Align(
            alignment: AlignmentDirectional(0.92, -0.89),
            child: Text(
              'TEAM DRAFT',
              style: TextStyle(
                fontFamily: 'Poller One',
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Colors.tealAccent,
                shadows: [
                  Shadow(
                    color: const Color.fromARGB(135, 255, 254, 254),
                    offset: Offset(0, 0),
                    blurRadius: 40.0,
                  )
                ],
              ),
            ),
          ),

          // Temporizador
          Align(
            alignment: AlignmentDirectional(-0.9, -0.85),
            child: Container(
              width: 94.0,
              height: 57.0,
              decoration: BoxDecoration(
                color: Color(0xE0C7292B),
                border: Border.all(color: Color.fromARGB(200, 152, 1, 1), width: 3.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4.0,
                    color: Colors.black45,
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '2:00',
                  style: TextStyle(
                    fontFamily: 'Kdam Thmor Pro',
                    fontSize: 30.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Contenedor con el nombre de usuario
          Align(
            alignment: AlignmentDirectional(0.93, -0.03),
            child: Container(
              width: 120.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color:  Color.fromARGB(185, 51, 144, 197), // Color del borde
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
                  color:  Color.fromARGB(255, 0, 0, 0), // Color del texto
                  fontSize: 12.0, // Tamaño del texto
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),


          // Botón de "Listo" con el ícono de verificación
          Align(
            alignment: AlignmentDirectional(0.66, -0.04),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PenaltyGame()), // Navega a la pantalla de MVP (tanda de penales)
                );
              },
              child: Container(
                width: 90.0,
                height: 90.0,
                decoration: BoxDecoration(
                  color: Color(0xFF39D2C0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Color.fromARGB(190, 11, 87, 200),
                    width: 3.0,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60.0,
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

  // Método para construir los botones de los espacios de jugadores
  List<Widget> _buildPlayerSlots() {
    return [
      _playerSlotButtonDEL(-0.35, -0.7, 1),
      _playerSlotButtonDEL(0.35, -0.7, 2),
      _playerSlotButtonDEL(0.0, -0.8, 3),
      _playerSlotButtonMID(-0.20, -0.1, 1),
      _playerSlotButtonMID(0.20, -0.1, 2),
      _playerSlotButtonDEF(-0.35, 0.5, 1),
      _playerSlotButtonDEF(0.35, 0.5, 2),
      _playerSlotButtonGK(0.0, 0.85),
    ];
  }

Widget _playerSlotButtonDEF(double x, double y, int buttonIndex) {
  return Align(
    alignment: Alignment(x, y),
    child: ElevatedButton(
      onPressed: () {
        // Abrir diálogo de selección solo si no se ha seleccionado un delantero para ese botón
        if (buttonIndex == 1 && !_playerSelected_DEF_1) {
          showDefensasForButton(context, 1);
        } else if (buttonIndex == 2 && !_playerSelected_DEF_2) {
          showDefensasForButton(context, 2);
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
          fontSize: 50.0,
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

Widget _playerSlotButtonGK(double x, double y) {
  return Align(
    alignment: Alignment(x, y),
    child: ElevatedButton(
      onPressed: () {
        // Mostrar los jugadores al presionar el botón
        showAllGK(context);
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
          fontSize: 50.0,
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
      return AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Delanteros').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var playerDocs = snapshot.data!.docs;

              // Mostrar en cuadrícula
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.64,
                ),
                itemCount: playerDocs.length,
                itemBuilder: (context, index) {
                  var playerData = playerDocs[index].data() as Map<String, dynamic>;
                  String playerId = playerDocs[index].id;

                  // Verificar si el jugador ya ha sido seleccionado
                  bool isSelected = selectedPlayers.contains(playerId);

                  return GestureDetector(
                    onTap: () {
                      // Si el jugador ya ha sido seleccionado, no permitir seleccionarlo de nuevo
                      if (isSelected) {
                        print('${playerData['name']} ya ha sido seleccionado.');
                        return; // Salir de la función si el jugador ya está seleccionado
                      }

                      // Verifica cuál botón ha llamado la selección
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

                      // Agregar el jugador al set de seleccionados
                      selectedPlayers.add(playerId);
                    },
                    child: Opacity(
                      opacity: isSelected ? 0.5 : 1.0, // Si está seleccionado, hacer la carta semitransparente
                      child: PlayerCard(
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
}
////////////////////////// MOSTRAR DELANTEROS /////////////////////////


////////////////////////// MOSTRAR MEDIOCAMPISTAS /////////////////////////
bool _playerSelected_MID_1 = false;
bool _playerSelected_MID_2 = false;

Set<String> selectedPlayers_MID = {};

void showMediocampistasForButton(BuildContext context, int buttonIndex) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Mediocampistas').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var playerDocs = snapshot.data!.docs;

              // Mostrar en cuadrícula
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.64,
                ),
                itemCount: playerDocs.length,
                itemBuilder: (context, index) {
                  var playerData = playerDocs[index].data() as Map<String, dynamic>;
                  String playerId = playerDocs[index].id;

                  // Verificar si el jugador ya ha sido seleccionado
                  bool isSelected = selectedPlayers.contains(playerId);

                  return GestureDetector(
                    onTap: () {
                      // Si el jugador ya ha sido seleccionado, no permitir seleccionarlo de nuevo
                      if (isSelected) {
                        print('${playerData['name']} ya ha sido seleccionado.');
                        return; // Salir de la función si el jugador ya está seleccionado
                      }

                      // Verifica cuál botón ha llamado la selección
                      if (buttonIndex == 1 && !_playerSelected_MID_1) {
                        _playerSelected_MID_1 = true;
                        _addToDraft(playerId, playerData, context);
                      } else if (buttonIndex == 2 && !_playerSelected_MID_2) {
                        _playerSelected_MID_2 = true;
                        _addToDraft(playerId, playerData, context);
                      }

                      // Agregar el jugador al set de seleccionados
                      selectedPlayers.add(playerId);
                    },
                    child: Opacity(
                      opacity: isSelected ? 0.5 : 1.0, // Si está seleccionado, hacer la carta semitransparente
                      child: PlayerCard(
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
}


bool _playerSelected_DEF_1 = false;
bool _playerSelected_DEF_2 = false;

Set<String> selectedPlayers_DEF = {};

void showDefensasForButton(BuildContext context, int buttonIndex) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Defensas').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var playerDocs = snapshot.data!.docs;

              // Mostrar en cuadrícula
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.64,
                ),
                itemCount: playerDocs.length,
                itemBuilder: (context, index) {
                  var playerData = playerDocs[index].data() as Map<String, dynamic>;
                  String playerId = playerDocs[index].id;

                  // Verificar si el jugador ya ha sido seleccionado
                  bool isSelected = selectedPlayers.contains(playerId);

                  return GestureDetector(
                    onTap: () {
                      // Si el jugador ya ha sido seleccionado, no permitir seleccionarlo de nuevo
                      if (isSelected) {
                        print('${playerData['name']} ya ha sido seleccionado.');
                        return; // Salir de la función si el jugador ya está seleccionado
                      }

                      // Verifica cuál botón ha llamado la selección
                      if (buttonIndex == 1 && !_playerSelected_DEF_1) {
                        _playerSelected_DEF_1 = true;
                        _addToDraft(playerId, playerData, context);
                      } else if (buttonIndex == 2 && !_playerSelected_DEF_2) {
                        _playerSelected_DEF_2 = true;
                        _addToDraft(playerId, playerData, context);
                      }

                      // Agregar el jugador al set de seleccionados
                      selectedPlayers.add(playerId);
                    },
                    child: Opacity(
                      opacity: isSelected ? 0.5 : 1.0, // Si está seleccionado, hacer la carta semitransparente
                      child: PlayerCard(
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
}

//////////////////////// ADD TO DRAFT COLLECTION USER/////////////////////////////////////
void _addToDraft(String playerId, Map<String, dynamic> playerData, BuildContext context) async {
  // Obtener el usuario actual
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    // Referencia al documento del usuario actual
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    // Añadir el jugador a la subcolección "my_draft"
    await userRef.collection('my_draft').doc(playerId).set({
      'name': playerData['name'],
      'position': playerData['position'],
      'level': playerData['level'],
      'country': playerData['country'],
      'image': playerData['image'],
      'shooting_options': playerData['shooting_options'],
    });

     Navigator.pop(context);

    // Mostrar confirmación (opcional)
    print('${playerData['name']} ha sido añadido a my_draft.');
  }
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
          fontSize: 50.0,
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
          fontSize: 50.0,
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
              
              // Mostrar en cuadricula
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.64,
                ),
                itemCount: playerDocs.length,
                itemBuilder: (context, index) {
                  var playerData = playerDocs[index].data() as Map<String, dynamic>;

                  return PlayerCard(
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
