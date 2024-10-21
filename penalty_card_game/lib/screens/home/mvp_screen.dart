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

  // Maneja la acción cuando el jugador ataja
  void handlePlayerSave(int row, int col) {
    setState(() {
      playerSelectedTiles = get3x3Zone(row, col); // El golero ataja automáticamente
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

  // Genera una zona 3x3 de atajadas para el golero
  List<List<int>> get3x3Zone(int row, int col) {
    List<List<int>> selectedTiles = [];
    int startRow = (row - 1 < 0) ? 0 : (row + 1 > 4) ? 2 : row - 1;
    int startCol = (col - 1 < 0) ? 0 : (col + 1 > 6) ? 4 : col - 1;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        selectedTiles.add([startRow + i, startCol + j]);
      }
    }
    return selectedTiles;
  }

  // Seleccionar automáticamente una zona de atajada para la CPU
  void cpuSelectSaveZone() {
    setState(() {
      int row = Random().nextInt(3) + 1;
      int col = Random().nextInt(5) + 1;
      cpuSelectedTiles = get3x3Zone(row, col);
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

  // Genera las opciones de disparo basadas en el atributo 'shooting_options' del jugador
  List<List<int>> generateShootingOptions(int optionsCount) {
    List<List<int>> shootingOptions = [];
    Random random = Random();

    // Generar posiciones aleatorias en la matriz hasta obtener la cantidad necesaria de opciones
    while (shootingOptions.length < optionsCount) {
      int row = random.nextInt(5);  // Hay 5 filas en la matriz (de 0 a 4)
      int col = random.nextInt(7);  // Hay 7 columnas en la matriz (de 0 a 6)
      List<int> option = [row, col];

      // Evitar duplicados
      if (!shootingOptions.contains(option)) {
        shootingOptions.add(option);
      }
    }

    return shootingOptions;
  }
}
