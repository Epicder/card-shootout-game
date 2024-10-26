import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:penalty_card_game/screens/home/home_screen.dart';
import 'dart:math';
import 'package:user_repository/user_repository.dart';
import 'package:penalty_card_game/player_cards/player_card_mvp.dart';

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

  // Equipo del usuario (cargado desde Firebase)
  List<Map<String, dynamic>> userTeam = [];
  List<Map<String, dynamic>> usedPlayers = []; // Jugadores que ya ejecutaron
  Map<String, dynamic>? selectedPlayer; // Jugador seleccionado para ejecutar el penal
  Map<String, dynamic>? goalkeeper; // Golero seleccionado automáticamente
  bool isLoading = true; // Indicador de carga
  bool showPlayerList = true; // Controlar si se muestra la lista de jugadores

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        fetchUserData(user.uid);
        fetchUserTeam(user.uid); // Asegúrate de llamar a esta función para cargar el equipo
      }
    });
  }

  // Obtener datos del usuario desde Firebase
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

  // Obtener el equipo del usuario desde Firebase
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla con opacidad
          Positioned.fill(
            child: Opacity(
              opacity: 1, // Ajusta la opacidad aquí
              child: Image.asset(
                'assets/fondo_penales.png', // Asegúrate de que esta ruta sea correcta
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Texto "Selecciona tu ejecutante" arriba de la lista de jugadores
          if (showPlayerList)
            Positioned(
              left: 30,
              top: 20, // Ajusta la posición del texto en la pantalla
              child: Text(
                "SELECCIONA \nTU EJECUTANTE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SPORT',
                  fontSize: 25.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 230, 7),
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
              ),
            ),
          // Colocar los botones de los jugadores a la izquierda
          if (showPlayerList)
            Positioned(
              left: 40,
              top: 75,
              bottom: 10,
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
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedPlayer = player;
                                    usedPlayers.add(player);
                                    shootingOptions = generateShootingOptions(player['shooting_options']);
                                    showPlayerList = false; // Ocultar la lista de jugadores
                                    if (usedPlayers.length == userTeam.length - 1) {
                                      usedPlayers.clear();
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  backgroundColor: const Color.fromARGB(255, 199, 189, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 8,
                                  shadowColor: Color.fromARGB(255, 0, 0, 0),
                                ),
                                child: Text(
                                  player['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: '',
                                    fontSize: 20.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
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
            left: 175, // Ajusta para alinear el arco con la matriz
            child: Container(
              width: 430, // Ajusta el tamaño horizontal del contenedor para que coincida con la matriz
              height: 225, // Ajusta el tamaño vertical del contenedor
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.white, // Color para los postes laterales
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
                    color: const Color.fromARGB(211, 0, 0, 0).withOpacity(0.7), // Color de la sombra
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
            top: 10, // Ajusta para mover la matriz hacia abajo o arriba
            left: 190, // Ajusta para mover la matriz hacia la izquierda o derecha
            child: Column(
              children: [
                // Marcador
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                  margin: const EdgeInsets.only(bottom: 20, top: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 4.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 12,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "${currentUser?.name ?? 'Tú Fc'}  $playerScore  |  $cpuScore  CPU",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                      letterSpacing: 1.5,
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
                        onEnter: (_) => _onHoverEnter(row, col),
                        onExit: (_) => _onHoverExit(),
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
                // Mostrar el mensaje "Ataja (nombre del golero)" cuando sea el turno del usuario de atajar
                if (!isPlayerTurn)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "GK TURN  -  ${goalkeeper?['name'] ?? 'Golero'}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 250, 238, 0),
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.8),
                            offset: Offset(2, 2),
                          ),
                        ],
                        decorationColor: Colors.black.withOpacity(0.9),
                        decorationThickness: 8,
                      ),
                    ),
                  ),
                // Mostrar el mensaje "EJECUTA (nombre del jugador)" cuando sea el turno de disparar
                if (isPlayerTurn && selectedPlayer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "PLAYER SHOOTING  -  ${selectedPlayer?['name'] ?? 'Jugador'}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 250, 238, 0),
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
                            offset: Offset(2, 2),
                          ),
                        ],
                        decorationColor: Colors.black.withOpacity(0.8),
                        decorationThickness: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Muestra el cuadro que está siendo "hovered" (cuando el mouse pasa por encima)
  void _onHoverEnter(int row, int col) {
    setState(() {
      hoveredTile = [row, col];
    });
  }

  void _onHoverExit() {
    setState(() {
      hoveredTile = null;
    });
  }

  // Maneja la acción cuando el jugador dispara
  void handlePlayerShoot(int row, int col) {
    // Verifica que el disparo esté dentro de las opciones de disparo válidas
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
            isPlayerTurn = false;
            playerPenalties++;
            selectedPlayer = null; // Reiniciar la selección para el siguiente penal
            showPlayerList = false; // Mantener oculta la lista durante la atajada

            // Si ya todos los jugadores ejecutaron, reiniciar la lista de usados
            if (usedPlayers.length == userTeam.length - 1) {
              usedPlayers.clear();
            }

            if (!gameEnded) handleNextRound(); // Llamar a la función para pasar al siguiente turno
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
    int goalkeeperZoneSize = 2; // Valor por defecto para el tamaño de la zona, correspondiente a 4 shooting options

    // Definir el tamaño de la zona basado en las shooting_options
    if (goalkeeperShootingOptions == 4) {
      goalkeeperZoneSize = 2; // 2x2 área
    } else if (goalkeeperShootingOptions == 6) {
      goalkeeperZoneSize = 3; // 3x3 área
    } else if (goalkeeperShootingOptions == 8) {
      goalkeeperZoneSize = 4; // 4x4 área
    } else {
      // Opcional: Manejar un valor inesperado de shooting options
      print("Error: Shooting options del golero no son válidos");
    }

    setState(() {
      playerSelectedTiles = getGoalkeeperZone(row, col, goalkeeperZoneSize); // Zona determinada
      cpuSelectShootZone();
      checkGoalOrSave();
      Future.delayed(Duration(seconds: 1), () {
        clearMatrix();
        setState(() {
          isPlayerTurn = true;
          cpuPenalties++;
          showPlayerList = true; // Volver a mostrar la lista de jugadores cuando sea turno del jugador
          if (!gameEnded) handleNextRound(); // Llamar a la función para pasar al siguiente turno
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

  // Función que maneja la lógica para avanzar al siguiente turno
  void handleNextRound() {
    if (playerPenalties == cpuPenalties) {
      if (playerPenalties < 5) {
        // Continuar el juego si ambos han ejecutado menos de 5 penales
        return;
      } else if (playerPenalties == 5) {
        // Si ambos han ejecutado 5 penales, verificar si alguien ha ganado
        if (playerScore != cpuScore) {
          endGame();
        }
      } else {
        // Después de 5 penales, el juego entra en muerte súbita
        if ((playerScore > cpuScore) || (cpuScore > playerScore)) {
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
      resultMessage = "¡Ganaste la tanda de penales!";
    } else {
      resultMessage = "La CPU ganó la tanda de penales.";
    }

    // Mostrar diálogo al final del juego
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre el diálogo tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fin del juego"),
          content: Text(resultMessage),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                resetGame(); // Reiniciar el juego
              },
              child: Text("Reiniciar partido"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Salir al menú (debes tener esta pantalla configurada)
                );
              },
              child: Text("Salir al menú"),
            ),
          ],
        );
      },
    );
  }

  // Limpia la matriz después de cada penal
  void clearMatrix() {
    playerSelectedTiles.clear();
    cpuSelectedTiles.clear();
    shootingOptions.clear(); // Limpiar las opciones de disparo al terminar el penal
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
    setState(() {
      int row = Random().nextInt(3) + 1;
      int col = Random().nextInt(5) + 1;
      cpuSelectedTiles = getGoalkeeperZone(row, col, 3); // 3x3 fijo para la CPU
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

  // Verificar si fue gol o atajada
  void checkGoalOrSave() {
    if (isPlayerTurn) {
      if (cpuSelectedTiles.any((tile) => tile[0] == playerSelectedTiles[0][0] && tile[1] == playerSelectedTiles[0][1])) {
        print("CPU atajo");
      } else {
        playerScore++;
        print("USR gol");
      }
    } else {
      if (playerSelectedTiles.any((tile) => tile[0] == cpuSelectedTiles[0][0] && tile[1] == cpuSelectedTiles[0][1])) {
        print("USR atajo");
      } else {
        cpuScore++;
        print("CPU gol");
      }
    }
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
