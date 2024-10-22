import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:user_repository/user_repository.dart';


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

  @override
  void initState() {
    super.initState();
    // Obtener el UserID del usuario autenticado
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        fetchUserData(user.uid); // Obtener datos del usuario
        fetchUserTeam(user.uid); // Cargar equipo seleccionado desde Firebase
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
      goalkeeper = userTeam.firstWhere((player) => player['position'] == 'Goalkeeper'); // Seleccionar el golero
      isLoading = false; // Finaliza la carga
    });

    print("Equipo cargado correctamente: $userTeam");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Penalty Shootout"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el marcador actual del juego
            Text(
              "${currentUser?.name ?? 'Tú Fc'}: $playerScore | CPU: $cpuScore",
              style: TextStyle(fontSize: 24),
            ),
            // Mostrar el ganador si el juego ha terminado
            if (gameEnded)
              Column(
                children: [
                  Text(
                    playerScore > cpuScore ? 'Jugador Gana!' : 'CPU Gana!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: resetGame,
                    child: Text('Reiniciar Tanda de Penales'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (isLoading)
              // Mostrar indicador de carga mientras se cargan los datos del equipo
              CircularProgressIndicator()
            else
              Expanded(
                child: Column(
                  children: [
                    // Seleccionar un jugador para ejecutar el penal si es turno del jugador
                    if (isPlayerTurn && selectedPlayer == null)
                      Column(
                        children: [
                          Text("Selecciona un jugador para ejecutar el penal:"),
                          for (var player in userTeam.where((p) => p['position'] != 'Goalkeeper' && !usedPlayers.contains(p)))
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedPlayer = player;
                                  usedPlayers.add(player); // Agregar el jugador a la lista de usados
                                  // Generar las posiciones aleatorias de disparo según 'shooting_options'
                                  shootingOptions = generateShootingOptions(player['shooting_options']);
                                  // Reiniciar la lista de jugadores si todos han ejecutado
                                  if (usedPlayers.length == userTeam.length - 1) {
                                    usedPlayers.clear();
                                  }
                                });
                              },
                              child: Text("${player['name']} - ${player['position']}"),
                            ),
                          const SizedBox(height: 20),
                        ],
                      )
                    else if (isPlayerTurn && selectedPlayer != null)
                      // Mostrar el jugador seleccionado para ejecutar el penal
                      Text("Jugador seleccionado: ${selectedPlayer!['name']}"),

                    // Mostrar el golero automáticamente si es turno de atajar
                    if (!isPlayerTurn) Text("Ataja el golero: ${goalkeeper!['name']}"),

                    const SizedBox(height: 20),

                    // Mostrar la matriz de 7x5 donde se ejecutan los penales
                    SizedBox(
                      width: 350,
                      height: 250,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: 35,
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
                                    border: Border.all(color: Colors.black),
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
            const SizedBox(height: 20)
          ],
        ),
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

  // Función que maneja el fin del juego y guarda los resultados en Firebase
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
  }

  // Limpia la matriz después de cada penal
  void clearMatrix() {
    playerSelectedTiles.clear();
    cpuSelectedTiles.clear();
    shootingOptions.clear(); // Limpiar las opciones de disparo al terminar el penal
  }

  // Resetea el juego para empezar una nueva tanda
  void resetGame() {
    setState(() {
      playerScore = 0;
      cpuScore = 0;
      playerPenalties = 0;
      cpuPenalties = 0;
      isPlayerTurn = true;
      gameEnded = false;
      clearMatrix();
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
      return const Color.fromARGB(255, 12, 86, 235);
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
