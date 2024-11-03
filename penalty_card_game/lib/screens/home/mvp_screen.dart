import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:penalty_card_game/screens/home/home_screen.dart';
import 'dart:math';
import 'package:user_repository/user_repository.dart';
import 'package:penalty_card_game/player_cards/player_card_mvp.dart';
import 'package:penalty_card_game/firestore_service.dart';
import 'dart:ui';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla con opacidad
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/fondo_penales.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          if (showPlayerList)
            Positioned(
              left: 200,  // Alineado con la matriz
              top: 340,  // Colocado justo debajo de la matriz
              child: Text(
                "CHOOSE YOUR SHOOTER",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Speedway',
                  fontSize: 23.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 230, 7),
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: const Color.fromARGB(255, 10, 10, 10).withOpacity(1),
                      offset: Offset(5, 2),
                    ),
                      Shadow(
                      color: const Color.fromARGB(255, 247, 229, 39).withOpacity(0.53), // Verde con opacidad para el glow
                      blurRadius: 40.0, // Radio del blur para el glow
                    ),
                  ],
                ),
              ),
            ),
          // Colocar los botones de los jugadores a la izquierda
          if (showPlayerList)
            Positioned(
              left: 35,
              top: 20,
              bottom: 0,
              child: SizedBox(
                width: 100,
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
                                style: TextButton.styleFrom(
                                elevation: 6.0,
                                backgroundColor: const Color.fromRGBO(91, 196, 95, 1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 10.0),
                                shadowColor: const Color.fromARGB(255, 75, 255, 114).withOpacity(1),
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                ),
                                ),
                                
                                child: Text(
                                  player['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                  fontFamily: 'SPORT',  // Si deseas puedes cambiar la fuente aquí
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 227, 228, 216),
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Color.fromARGB(71, 0, 0, 0),
                                      offset: Offset(2, 2),
                                    ),
                                  ],
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
            top: 100, // Ajusta la posición del contenedor
            left: 178, // Ajusta para alinear el arco con la matriz
            child: Container(
              width: 430, // Ajusta el tamaño horizontal del contenedor para que coincida con la matriz
              height: 225, // Ajusta el tamaño vertical del contenedor
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.white,
                    width: 10.0, // Grosor de los postes
                  ),
                  right: BorderSide(
                    color: Colors.white, // Color para el otro poste
                    width: 10.0, // Grosor de los postes
                  ),
                  top: BorderSide(
                    color: Colors.white, // Color para el travesaño
                    width: 10.0, // Grosor del travesaño (puede ser un poco más grueso que los postes)
                  ),
                  // Si deseas agregar un borde inferior opcional
                  bottom: BorderSide(
                    color: const Color.fromARGB(68, 10, 52, 0), // Sin borde inferior, representa el césped
                    width: 20,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(211, 0, 0, 0).withOpacity(0.56), // Color de la sombra
                    blurRadius: 15, // Difuminado de la sombra
                    offset: Offset(4, 5), // Desplazamiento de la sombra
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1), // Espacio entre los bordes externos e internos
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: const Color.fromARGB(255, 178, 178, 178), // Color para el borde interno de los postes
                        width: 2.0, // Grosor del borde interno
                      ),
                      right: BorderSide(
                        color: Color.fromARGB(255, 178, 178, 178), // Color para el borde interno del otro poste
                        width: 2.0, // Grosor del borde interno
                      ),
                      top: BorderSide(
                        color: Color.fromARGB(195, 178, 178, 178), // Color para el borde interno del travesaño
                        width: 2.0, // Grosor del borde interno del travesaño
                      ),
                      bottom: BorderSide(
                        color: Colors.transparent, // Sin borde inferior, representa el césped
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Posicionar el contenido del juego (matriz y marcador)
          Positioned(
            top: 34, // Ajusta para mover la matriz hacia abajo o arriba
            left: 193, // Ajusta para mover la matriz hacia la izquierda o derecha
            child: Column(
              children: [
                // Marcador
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
                  margin: const EdgeInsets.only(bottom: 20, top: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(91, 196, 95, 1).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 96, 255, 56).withOpacity(0.2),
                      width: 2.0,
                    ),
                    boxShadow:[
                      BoxShadow(
                        color: const Color.fromARGB(132, 82, 194, 82).withOpacity(0.5),
                        blurRadius: 18,
                        offset: Offset(5, 0),
                      ),
                    ],
                  ),
                  child: Text(
                    "${currentUser?.name ?? 'Tú Fc'}  $playerScore  |  $cpuScore  CPU",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 224, 224, 224),
                      letterSpacing: 2,
                      fontFamily: 'SPORT',
                    ),
                  ),
                ),
                // Mostrar la matriz de 7x5 centrada
                SizedBox(
                  width: 400, // Ajusta el tamaño total horizontal de la matriz
                  height: 250, // Ajusta el tamaño total vertical de la matriz
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              margin: const EdgeInsets.all(3.5),
                              decoration: BoxDecoration(
                                color: getColorForTile(row, col),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 136, 136, 136),
                                  width: 2,
                                ),
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
          Positioned(
            left: -15, // Ajusta la posición a la izquierda
            top: 95, // Alinea con la parte superior de la pantalla
            child: isPlayerTurn && selectedPlayer != null
              ? PlayerCardMVP( // Mostrar la carta del ejecutante cuando sea el turno del jugador
                  playerName: selectedPlayer!['name'],
                  playerPosition: selectedPlayer!['position'],
                  playerLevel: selectedPlayer!['level'],
                  playerCountry: selectedPlayer!['country'],
                  playerImage: selectedPlayer!['image'],
                  shootingOptions: selectedPlayer!['shooting_options'],
                )
              : (!isPlayerTurn && goalkeeper != null) // Mostrar la carta del golero cuando sea su turno de atajar
                ? PlayerCardMVP(
                    playerName: goalkeeper!['name'],
                    playerPosition: goalkeeper!['position'],
                    playerLevel: goalkeeper!['level'],
                    playerCountry: goalkeeper!['country'],
                    playerImage: goalkeeper!['image'],
                    shootingOptions: goalkeeper!['shooting_options'], // Atributos del golero
                  )
                : SizedBox.shrink(), // No mostrar nada si no es el turno del golero ni del ejecutante
          ),
          // Mostrar la carta del golero CPU cuando el usuario está ejecutando el penal
          Positioned(
            right: -25, // Ajusta la posición a la derecha
            top: 95,    // Alinea con la parte superior de la pantalla
            child: isPlayerTurn && cpuGoalkeeper != null // Mostrar la carta del golero CPU cuando el jugador ejecuta
              ? PlayerCardMVP(
                  playerName: cpuGoalkeeper!['name'],
                  playerPosition: cpuGoalkeeper!['position'],
                  playerLevel: cpuGoalkeeper!['level'],
                  playerCountry: cpuGoalkeeper!['country'],
                  playerImage: cpuGoalkeeper!['image'],
                  shootingOptions: cpuGoalkeeper!['shooting_options'],
                )
              : SizedBox.shrink(), // No mostrar nada si no es el turno adecuado
          ),
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
              Timer(Duration(milliseconds: 2000), () {
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
  // Verifica que el disparo esté dentro de las opciones de disparo válidas
  if (shootingOptions.any((option) => option[0] == row && option[1] == col)) {
    setState(() {
      // Selecciona el cuadrado del jugador
      playerSelectedTiles = [
        [row, col]
      ];
      // La CPU selecciona una zona de atajada
      cpuSelectSaveZone();
      // Comprueba si fue gol o atajada
      checkGoalOrSave();

      // Después de un pequeño retraso, limpiamos la matriz y avanzamos el turno
      Future.delayed(Duration(seconds: 1), () {
        clearMatrix(); // Limpia la matriz de shooting options y casillas seleccionadas

        setState(() {
          isPlayerTurn = false; // Cambia el turno al portero
          playerPenalties++;

          // Una vez que el jugador dispara, eliminamos el jugador seleccionado
          selectedPlayer = null;

          // Oculta la lista de jugadores durante la atajada
          showPlayerList = false;

          // Si todos los jugadores han disparado, reiniciar la lista de jugadores usados
          if (usedPlayers.length == userTeam.length - 1) {
            usedPlayers.clear();
          }

          if (!gameEnded) {
            handleNextRound(); // Continua con el próximo turno si el juego no ha terminado
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
    int goalkeeperZoneSize = 2;  // Valor por defecto para el tamaño de la zona, correspondiente a 4 shooting options

    // Definir el tamaño de la zona basado en las shooting_options
    if (goalkeeperShootingOptions == 4) {
      goalkeeperZoneSize = 2;  // 2x2 área
    } else if (goalkeeperShootingOptions == 6) {
      goalkeeperZoneSize = 3;  // 3x3 área
    } else if (goalkeeperShootingOptions == 8) {
      goalkeeperZoneSize = 4;  // 4x4 área
    } else {
      print("Error: Shooting options del golero no son válidos");
    }

    setState(() {
      playerSelectedTiles = getGoalkeeperZone(row, col, goalkeeperZoneSize);  // Zona determinada
      cpuSelectShootZone();
      checkGoalOrSave();
      Future.delayed(Duration(seconds: 1), () {
        clearMatrix();
        setState(() {
          isPlayerTurn = true;  // Cambia el turno al jugador
          cpuPenalties++;
          showPlayerList = true;  // Vuelve a mostrar la lista de jugadores cuando sea turno del jugador
          if (!gameEnded) handleNextRound();  // Llamar a la función para pasar al siguiente turno
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
      resultMessage = "🎉 Congratulations! You won the penalty shootout.";
    } else {
      resultMessage = "😢 You lost the penalty shootout. Try again!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 55, 196, 71).withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              side: BorderSide(color: Colors.white, width: 2.0),
            ),
            title: Text("Game Ended"),
            titleTextStyle: TextStyle(
              color: const Color.fromARGB(255, 235, 235, 235),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: const Color.fromARGB(255, 230, 253, 125).withOpacity(0.5),
                  offset: Offset(2, 0),
                ),
              ],
            ),
            content: Text(resultMessage),
            contentTextStyle: TextStyle(
              fontSize: 16.0,
              color: const Color.fromARGB(255, 235, 235, 235),
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: const Color.fromARGB(255, 230, 253, 125).withOpacity(0.5),
                  offset: Offset(0, 0),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  resetGame(); // Reiniciar el juego
                },
                child: Text("Restart the match"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 235, 235, 235),
                  backgroundColor: const Color.fromARGB(255, 29, 116, 39),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()), // Salir al menú (debes tener esta pantalla configurada)
                  );
                },
                child: Text("Exit to menu"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 235, 235, 235),
                  backgroundColor: const Color.fromARGB(255, 29, 116, 39),
                ),
              ),
            ],
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
    return Colors.white.withOpacity(0.8);
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