import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:penalty_card_game/screens/home/home_screen.dart';
import 'dart:math';
import 'package:user_repository/user_repository.dart';
import 'package:penalty_card_game/player_cards/player_card_mvp.dart';
import 'package:penalty_card_game/firestore_service.dart';
import 'package:google_fonts/google_fonts.dart';


class PenaltyShootoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Penalty Shootout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PenaltyGame(),
    );
  }
}

class PenaltyGame extends StatefulWidget {
  @override
  _PenaltyGameState createState() => _PenaltyGameState();
}

class _PenaltyGameState extends State<PenaltyGame> {
  MyUser? currentUser; // Usuario autenticado
  int playerScore = 0;
  int cpuScore = 0;
  int playerPenalties = 0;
  int cpuPenalties = 0;
  bool isPlayerTurn = true;
  bool gameEnded = false;
  List<List<int>> playerSelectedTiles = [];
  List<List<int>> cpuSelectedTiles = [];
  List<List<int>> shootingOptions = []; // Opciones de disparo generadas
  List<int>? hoveredTile;
  final FirestoreService firestoreService = FirestoreService();

  // Equipo del usuario (cargado desde Firebase)
  List<Map<String, dynamic>> userTeam = [];
  List<Map<String, dynamic>> usedPlayers = []; // Jugadores que ya ejecutaron
  Map<String, dynamic>? selectedPlayer; // Jugador seleccionado para ejecutar el penal
  Map<String, dynamic>? goalkeeper; // Golero seleccionado automáticamente
  Map<String, dynamic>? cpuGoalkeeper; // Golero de la CPU
  Map<String, dynamic>? randomCPUPlayer; // Jugador de campo aleatorio de la CPU
  bool isLoading = true; // Indicador de carga
  bool showPlayerList = true; // Controlar si se muestra la lista de jugadores

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        fetchUserData(user.uid);
        fetchUserTeam(user.uid);
        fetchCPUGoalkeeper(); // Asegúrate de llamar a esta función para cargar el equipo
      }
    });
  }

// firebase
  Future<void> fetchUserData(String userId) async {
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

  Future<void> fetchUserTeam(String userId) async {
    final teamSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_draft')
        .get();

    List<Map<String, dynamic>> team = [];
    for (var doc in teamSnapshot.docs) {
      team.add(doc.data());
    }

    setState(() {
      userTeam = team;
      goalkeeper = userTeam.firstWhere((player) => player['position'] == 'Goalkeeper', orElse: () => <String, dynamic>{}); // Seleccionar el golero
      isLoading = false; // Finaliza la carga
    });

    print("Equipo cargado correctamente: $userTeam");
  }

    // Función para obtener un golero CPU aleatorio
  void fetchCPUGoalkeeper() async {
    try {
      final randomGoalkeeper = await firestoreService.getRandomCPUGoalkeeper();
      setState(() {
        cpuGoalkeeper = randomGoalkeeper;
      });
    } catch (e) {
      print("Error al cargar el golero de la CPU: $e");
    }
  }

  Future<void> fetchRandomCPUPlayer() async {
  try {
    final player = await firestoreService.getRandomCPUPlayer(); // Suponiendo que `getRandomCPUPlayer()` filtra jugadores de campo
    setState(() {
      randomCPUPlayer = player;
    });
  } catch (e) {
    print("Error al cargar un jugador de campo aleatorio de la CPU: $e");
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Fondo de pantalla con opacidad y desenfoque
        Positioned.fill(
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(100, 0), // Ajusta el valor en X para mover a la izquierda o derecha
                child: Transform.scale(
                  scale: 2, // Cambia el valor para ajustar el zoom (1.0 es el tamaño original)
                  child: Image.asset(
                    'assets/sta_tis.png', // Asegúrate de que esta ruta sea correcta
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  color: const Color.fromARGB(69, 41, 42, 41), // Esto permite que el blur se aplique sobre la imagen
                ),
              ),
            ],
          ),
        ),
        // Texto "Selecciona tu ejecutante" arriba de la lista de jugadores
        if (showPlayerList)
          Positioned(
            left: 20,  // Alineado con la matriz
            top: 30,  // Colocado justo debajo de la matriz
            child: Text(
              "SELECT\nYOUR SHOOTER",
              textAlign: TextAlign.center,
              style: GoogleFonts.graduate(  // Cambia la fuente aquí a la que prefieras
                fontSize: 15.0,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(248, 244, 232, 7),
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: const Color.fromARGB(248, 216, 4, 4),
                    offset: Offset(2, 1),
                  ),
                ],
              ),
            ),
          ),
        // Colocar los botones de los jugadores a la izquierda
        if (showPlayerList)
          Positioned(
            left: 25,
            top: 90,
            bottom: 68,
            child: SizedBox(
              width: 110,
              child: Column(
                children: [
                  if (!isLoading)
                    Expanded(
                      child: ListView.builder(
                        itemCount: userTeam.where((p) => p['position'] != 'Goalkeeper' && !usedPlayers.contains(p)).length,
                        itemBuilder: (context, index) {
                          var player = userTeam.where((p) => p['position'] != 'Goalkeeper' && !usedPlayers.contains(p)).elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedPlayer = player;  // Almacena el jugador seleccionado
                                  usedPlayers.add(player);  // Marca al jugador como usado
                                  shootingOptions = generateShootingOptions(player['shooting_options']);
                                  showPlayerList = false;  // Ocultar la lista de jugadores después de seleccionar
                                  if (usedPlayers.length == userTeam.length - 1) {
                                    usedPlayers.clear();  // Reinicia la lista de jugadores usados si ya se han usado todos
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 2.0),
                                backgroundColor: const Color.fromARGB(255, 32, 33, 33),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),  // Mantén el borde redondeado
                                  side: BorderSide(
                                    color: const Color.fromARGB(248, 5, 238, 137),  // Agrega un borde blanco
                                    width: 2,  // Grosor del borde
                                  ),
                                ),
                                elevation: 10,  // Sombra bajo el botón
                                shadowColor: const Color.fromARGB(255, 0, 0, 0),  // Ajusta la opacidad de la sombra
                              ),
                              child: Text(
                                player['name'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.graduate(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Color.fromARGB(248, 0, 0, 0),
                                        offset: Offset(2, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Insertar el "arco" usando los bordes del contenedor detrás de la matriz
          Positioned(
            top: 98, // Ajusta la posición del contenedor
            left: 160, // Ajusta para alinear el arco con la matriz
            child: Container(
              width: 460, // Ajusta el tamaño horizontal del contenedor para que coincida con la matriz
              height: 230, // Ajusta el tamaño vertical del contenedor
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: const Color.fromARGB(255, 196, 195, 195), // Color para los postes laterales
                    width: 10.0, // Grosor de los postes
                  ),
                  right: BorderSide(
                    color: const Color.fromARGB(255, 196, 195, 195), // Color para el otro poste
                    width: 10.0, // Grosor de los postes
                  ),
                  top: BorderSide(
                    color: const Color.fromARGB(255, 196, 195, 195), // Color para el travesaño
                    width: 10.0, // Grosor del travesaño (puede ser un poco más grueso que los postes)
                  ),
                  // Si deseas agregar un borde inferior opcional
                  bottom: BorderSide(
                    color: const Color.fromARGB(169, 43, 44, 43), // Sin borde inferior, representa el césped
                    width: 0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.95), // Color de la sombra
                    blurRadius: 10, // Difuminado de la sombra
                    offset: Offset(4, 2), // Desplazamiento de la sombra
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1), // Espacio entre los bordes externos e internos
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: const Color.fromARGB(255, 255, 255, 255), // Color para el borde interno de los postes
                        width: 2.0, // Grosor del borde interno
                      ),
                      right: BorderSide(
                        color: Color.fromARGB(255, 248, 248, 248), // Color para el borde interno del otro poste
                        width: 2.0, // Grosor del borde interno
                      ),
                      top: BorderSide(
                        color: Color.fromARGB(195, 178, 178, 178), // Color para el borde interno del travesaño
                        width: 2.0, // Grosor del borde interno del travesaño
                      ),
                      bottom: BorderSide(
                        color: const Color.fromARGB(101, 9, 47, 0), // Sin borde inferior, representa el césped
                        width: 8.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Marcador (posiciona este contenedor para mover solo el marcador)
        Positioned(
          top: 15, // Ajusta la posición superior del marcador
          left: 242, // Ajusta la posición izquierda del marcador
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(6, 64, 64, 64),
              borderRadius: BorderRadius.circular(2.0),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(47, 53, 53, 51).withOpacity(0.9),
                  blurRadius: 5,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Text(
              "${currentUser?.name ?? 'Tú Fc'}  $playerScore  |  $cpuScore  CPU",
              style: GoogleFonts.nabla(
                fontSize: 30,
                fontWeight: FontWeight.w100,
                color: const Color.fromARGB(255, 255, 254, 254),
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Matriz de 7x5 (posiciona este contenedor para mover solo la matriz)
        Positioned(
          top: 115, // Ajusta la posición superior de la matriz
          left: 175, // Ajusta la posición izquierda de la matriz
          child: SizedBox(
            width: 430, // Tamaño horizontal de la matriz
            height: 260, // Tamaño vertical de la matriz
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // Mantener las 7 columnas
                mainAxisSpacing: 6.0,
                crossAxisSpacing: 1.0,
                childAspectRatio: 1.7, // Forma cuadrada
              ),
              itemCount: 35, // Mantener los 35 cuadrados (7x5)
              itemBuilder: (context, index) {
                int row = index ~/ 7;
                int col = index % 7;

                return MouseRegion(
                  child: GestureDetector(
                    onTap: () {
                      if (!gameEnded && (isPlayerTurn && selectedPlayer != null) || !isPlayerTurn) {
                        if (isPlayerTurn) {
                          handlePlayerShoot(row, col);
                        } else {
                          handlePlayerSave(row, col);
                        }
                      }
                    },
                    child: GridTile(
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: getColorForTile(row, col),
                          border: Border.all(
                            color: const Color.fromARGB(255, 166, 166, 166),
                            width: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: -30, // Ajusta la posición a la izquierda
          top: 70, // Alinea con la parte superior de la pantalla
          child: isPlayerTurn && selectedPlayer != null
            ? Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(56, 4, 158, 94), // Color de la sombra (ajusta el color para resaltado)
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(-43, 0),
                    ),
                  ],
                ),
                child: PlayerCardMVP(
                  playerName: selectedPlayer!['name'],
                  playerPosition: selectedPlayer!['position'],
                  playerLevel: selectedPlayer!['level'],
                  playerCountry: selectedPlayer!['country'],
                  playerImage: selectedPlayer!['image'],
                  shootingOptions: selectedPlayer!['shooting_options'],
                ),
              )
            : (!isPlayerTurn && goalkeeper != null)
              ? Container(
                  decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(56, 4, 158, 94), // Color de la sombra (ajusta el color para resaltado)
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(-43, 0),
                      ),
                    ],
                  ),
                  child: PlayerCardMVP(
                    playerName: goalkeeper!['name'],
                    playerPosition: goalkeeper!['position'],
                    playerLevel: goalkeeper!['level'],
                    playerCountry: goalkeeper!['country'],
                    playerImage: goalkeeper!['image'],
                    shootingOptions: goalkeeper!['shooting_options'],
                  ),
                )
              : SizedBox.shrink(),
        ),

        // Mostrar la carta del golero CPU cuando el usuario está atajando el penal
        Positioned(
          right: -32, // Ajusta la posición a la derecha
          top: 70,    // Alinea con la parte superior de la pantalla
          child: isPlayerTurn && cpuGoalkeeper != null
            ? Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(111, 171, 2, 2), // Color de la sombra (ajusta el color para resaltado)
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(45, 0),
                    ),
                  ],
                ),
                child: PlayerCardMVP(
                  playerName: cpuGoalkeeper!['name'],
                  playerPosition: cpuGoalkeeper!['position'],
                  playerLevel: cpuGoalkeeper!['level'],
                  playerCountry: cpuGoalkeeper!['country'],
                  playerImage: cpuGoalkeeper!['image'],
                  shootingOptions: cpuGoalkeeper!['shooting_options'],
                ),
              )
            : SizedBox.shrink(),
        ),
        // Mostrar la carta del jugador de campo aleatorio de la CPU cuando el usuario está atajando el penal
        Positioned(
          right: -32, // Ajusta la posición a la derecha
          top: 70,    // Alinea con la parte superior de la pantalla
          child: !isPlayerTurn && randomCPUPlayer != null // Mostrar la carta solo si es turno del usuario de atajar
            ? Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(111, 171, 2, 2), // Color de la sombra (ajusta el color para resaltado)
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(45, 0),
                    )
                  ],
                ),
                child: PlayerCardMVP(
                  playerName: randomCPUPlayer!['name'],
                  playerPosition: randomCPUPlayer!['position'],
                  playerLevel: randomCPUPlayer!['level'],
                  playerCountry: randomCPUPlayer!['country'],
                  playerImage: randomCPUPlayer!['image'],
                  shootingOptions: randomCPUPlayer!['shooting_options'],
                ),
              )
            : SizedBox.shrink(),
          ),
          /*  ------------------------------> Esto es para el dialog, es para hacer los cambios mas facil con el reload.
          Positioned(
  top: 40, // Ajusta la posición si es necesario
  right: 20,
  child: ElevatedButton(
    onPressed: endGame, // Llama a endGame() directamente
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple, // Color distintivo para reconocer el botón temporal
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      'Probar Diálogo',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  ),
),*/
        ],
      ),
    );
  }


void showGoalAnimation() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 1000,
          height: 1000,
          child: Lottie.asset(
            'assets/animations/confetti.json',
            repeat: false,
            fit: BoxFit.cover,
            onLoaded: (composition) {
              Timer(Duration(milliseconds: 2200), () {
                Navigator.of(context).pop();
              });
            },
          ),
        ),
      );
    },
  );
}

void showGoalAnimation2() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 600,
          height: 500,
          child: Lottie.asset(
            'assets/animations/goal.json',
            repeat: false,
            
            onLoaded: (composition) {
              Timer(Duration(milliseconds: 2350), () {
                Navigator.of(context).pop();
              });
            },
          ),
        ),
      );
    },
  );
}

void showGoalAnimation3() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(0),
        child: Container(
          width: 600,
          height: 500,
          child: Lottie.asset(
            'assets/animations/fireworks.json',
            repeat: false,
            
            onLoaded: (composition) {
              Timer(Duration(milliseconds: 2350), () {
                Navigator.of(context).pop();
              });
            },
          ),
        ),
      );
    },
  );
}

void checkGoalOrSave() {
  if (isPlayerTurn) {
    // Verifica si la CPU atajó el penal
    if (cpuSelectedTiles.any((tile) => tile[0] == playerSelectedTiles[0][0] && tile[1] == playerSelectedTiles[0][1])) {
      print("CPU atajó el disparo");
    } else {
      playerScore++;
      print("¡Gol del jugador!");
      showGoalAnimation();
      showGoalAnimation2();
      showGoalAnimation3();
    }
  } else {
    if (playerSelectedTiles.any((tile) => tile[0] == cpuSelectedTiles[0][0] && tile[1] == cpuSelectedTiles[0][1])) {
      print("El jugador atajó el disparo de la CPU");
    } else {
      cpuScore++;
      print("Gol de la CPU");
    }
  }
}


  void handlePlayerShoot(int row, int col) {
    if (shootingOptions.any((option) => option[0] == row && option[1] == col)) {
      setState(() {
        playerSelectedTiles = [
          [row, col]
        ];
        cpuSelectSaveZone();
        checkGoalOrSave();

        Future.delayed(Duration(seconds: 1), () {
          clearMatrix();

          setState(() {
            isPlayerTurn = false; // Cambia el turno al portero
            playerPenalties++;
            selectedPlayer = null;
            showPlayerList = false;

            if (usedPlayers.length == userTeam.length - 1) {
              usedPlayers.clear();
            }

            if (!gameEnded) {
              // Actualiza el ejecutante CPU antes de cambiar el turno
              fetchRandomCPUPlayer();
              handleNextRound(); // Cambia al próximo turno si el juego no ha terminado
            }
          });
        });
      });
    } else {
      print("El disparo no está dentro de las opciones válidas");
    }
  }

  void handlePlayerSave(int row, int col) {
    // Obtener las shooting_options del portero para determinar el tamaño del área
    int goalkeeperShootingOptions = goalkeeper!['shooting_options'];
    int goalkeeperZoneSize = 2;

    // Definir el tamaño de la zona basado en las shooting_options
    if (goalkeeperShootingOptions == 4) {
      goalkeeperZoneSize = 2;
    } else if (goalkeeperShootingOptions == 6) {
      goalkeeperZoneSize = 3;
    } else if (goalkeeperShootingOptions == 8) {
      goalkeeperZoneSize = 4;
    } else {
      print("Error: Shooting options del golero no son válidos");
    }

    setState(() {
      playerSelectedTiles = getGoalkeeperZone(row, col, goalkeeperZoneSize);
      cpuSelectShootZone();
      checkGoalOrSave();
      Future.delayed(Duration(seconds: 1), () {
        clearMatrix();
        setState(() {
          isPlayerTurn = true;
          cpuPenalties++;
          showPlayerList = true;
          if (!gameEnded) handleNextRound();
        });
      });
    });
  }

  // Función para determinar la zona de atajada del golero según su tamaño
  List<List<int>> getGoalkeeperZone(int row, int col, int size) {
    List<List<int>> selectedTiles = [];

    // Calcular las filas y columnas iniciales considerando los bordes de la matriz
    int startRow = max(0, row - (size ~/ 2));
    int startCol = max(0, col - (size ~/ 2));

    // Evitar que se salga del límite de la matriz
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (startRow + i < 5 && startCol + j < 7) {
          selectedTiles.add([startRow + i, startCol + j]);
        }
      }
    }
    return selectedTiles;
  }

// Maneja el siguiente turno
void handleNextRound() {
  // Verifica si ambos jugadores han ejecutado la misma cantidad de penales
  if (playerPenalties == cpuPenalties) {
    // Continuar si ambos han ejecutado menos de 5 penales
    if (playerPenalties < 5) {
      return;
    } else if (playerPenalties == 5) {
      // Verificar si alguien ha ganado después de 5 penales
      if (playerScore != cpuScore) {
        endGame();
      }
    } else {
      // Después de 5 penales, entra en muerte súbita
      if (playerScore != cpuScore) {
        endGame();
      }
    }
  }
}

void endGame() async {
  setState(() {
    gameEnded = true;
  });

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print("Error: Usuario no autenticado");
    return;
  }

  String uid = currentUser.uid;

  await FirebaseFirestore.instance.collection('users')
      .doc(uid)
      .collection('matches')
      .add({
    'playerScore': playerScore,
    'cpuScore': cpuScore,
    'date': DateTime.now(),
  }).then((value) {
    print("Resultado guardado exitosamente");
  }).catchError((error) {
    print("Error al guardar resultado: $error");
  });

  // Mostrar mensaje con el ganador
  String resultMessage;
  if (playerScore > cpuScore) {
    resultMessage = "You won the penalty shootout!";
  } else {
    resultMessage = "The CPU won the penalty shootout.";
  }

  // Mostrar diálogo al final del juego
  showDialog(
    context: context,
    barrierDismissible: false, // Evita que se cierre el diálogo tocando fuera
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color.fromARGB(0, 26, 26, 26),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 4, 61, 1), // Fondo oscuro con opacidad
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                blurRadius: 5,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "END OF THE MATCH",
                textAlign: TextAlign.center,
                style: GoogleFonts.bangers(
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 229, 233, 0),
                    fontSize: 50,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        offset: Offset(3, 3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                resultMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        offset: Offset(2, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      resetGame(); // Reinicia el juego
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "RESTART",
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomeScreen()), // Volver al menú principal
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "HOME",
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void clearMatrix() {
  setState(() {
    playerSelectedTiles.clear(); // Limpia las casillas seleccionadas por el jugador
    cpuSelectedTiles.clear();    // Limpia las casillas seleccionadas por la CPU
    shootingOptions.clear();     // Limpia las opciones de disparo
  });
}


void resetGame() {
    setState(() {
      playerScore = 0;
      cpuScore = 0;
      playerPenalties = 0;
      cpuPenalties = 0;
      isPlayerTurn = true;
      gameEnded = false;
      clearMatrix();
      
      // Reiniciar la lista de jugadores usados
      usedPlayers.clear(); 

      // Mostrar nuevamente la lista de jugadores desde el inicio
      showPlayerList = true;

      // Reiniciar el jugador seleccionado
      selectedPlayer = null; 
    });
  }

  // Seleccionar automáticamente una zona de atajada para la CPU
void cpuSelectSaveZone() {
  if (cpuGoalkeeper == null) return; // Asegúrate de que haya un golero cargado

  int shootingOptions = cpuGoalkeeper!['shooting_options'];
  int zoneSize = 2; // Por defecto, 2x2 (4 shooting options)

  if (shootingOptions == 6) {
    zoneSize = 3; // 3x3 área
  } else if (shootingOptions == 8) {
    zoneSize = 4; // 4x4 área
  }

  setState(() {
    int row = Random().nextInt(3) + 1;
    int col = Random().nextInt(5) + 1;
    cpuSelectedTiles = getGoalkeeperZone(row, col, zoneSize); // Definir el área de atajada
  });
}
  
  // Seleccionar automáticamente una zona de disparo para la CPU
void cpuSelectShootZone() {
    setState(() {
      int row = Random().nextInt(5);
      int col = Random().nextInt(7);
      cpuSelectedTiles = [
        [row, col]
      ];
    });
  }

  // Define los colores de los cuadros en la matriz
  Color getColorForTile(int row, int col) {
    if (cpuSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
      return Colors.red;
    } else if (playerSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
      return const Color.fromARGB(255, 91, 195, 107);
    } else if (shootingOptions.any((option) => option[0] == row && option[1] == col)) {
      // Resaltar las opciones de disparo disponibles en verde
      return const Color.fromARGB(255, 0, 59, 252);
    } else if (hoveredTile != null && hoveredTile![0] == row && hoveredTile![1] == col) {
      return const Color.fromARGB(255, 91, 195, 107);
    }
    return Colors.white;
  }

  List<List<int>> generateShootingOptions(int optionsCount) {
    List<List<int>> shootingOptions = [];
    Random random = Random();

    // Crear una lista de todas las posiciones disponibles en la matriz
    List<List<int>> allPositions = [];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 7; col++) {
        allPositions.add([row, col]);
      }
    }

    // Barajar la lista de posiciones para obtener aleatoriedad
    allPositions.shuffle(random);

    // Tomar las primeras 'optionsCount' posiciones de la lista barajada
    for (int i = 0; i < optionsCount; i++) {
      shootingOptions.add(allPositions[i]);
    }

    return shootingOptions;
  }
}