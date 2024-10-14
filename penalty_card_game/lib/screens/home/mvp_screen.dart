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
  MyUser? currentUser; // GUARDA LA CLASE MYUSER EN UNA VARIABLE currenUser
  int playerScore = 0;
  int cpuScore = 0;
  int playerPenalties = 0;
  int cpuPenalties = 0;
  bool isPlayerTurn = true;
  bool gameEnded = false;
  List<List<int>> playerSelectedTiles = [];
  List<List<int>> cpuSelectedTiles = [];
  List<int>? hoveredTile;

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
      appBar: AppBar(
        title: Text("Penalty Shootout"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${currentUser?.name ?? 'Tú Fc'}: $playerScore | CPU: $cpuScore",
              style: TextStyle(fontSize: 24),
            ),
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
            SizedBox(height: 20),
            Expanded(
              child: SizedBox(
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
                          if (!gameEnded) {
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
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  void _onHoverEnter(int row, int col) {
    if (isPlayerTurn || (row > 0 && row < 4 && col > 0 && col < 6)) {
      setState(() {
        hoveredTile = [row, col];
      });
    }
  }

  void _onHoverExit() {
    setState(() {
      hoveredTile = null;
    });
  }

  void handlePlayerShoot(int row, int col) {
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
          if (!gameEnded) handleNextRound();
        });
      });
    });
  }

  void handlePlayerSave(int row, int col) {
    if (row > 0 && row < 4 && col > 0 && col < 6) {
      setState(() {
        playerSelectedTiles = get3x3Zone(row, col);
        cpuSelectShootZone();
        checkGoalOrSave();
        Future.delayed(Duration(seconds: 1), () {
          clearMatrix();
          setState(() {
            isPlayerTurn = true;
            cpuPenalties++;
            if (!gameEnded) handleNextRound();
          });
        });
      });
    }
  }

  void handleNextRound() {
    // Si ambos jugadores han realizado la misma cantidad de disparos, verificar si el juego debe continuar
    if (playerPenalties == cpuPenalties) {
      if (playerPenalties < 5) {
        // Continuar la tanda regular
        return;
      } else if (playerPenalties == 5) {
        // Evaluar si hay un ganador tras los primeros 5 penales
        if (playerScore != cpuScore) {
          endGame();
        }
        // Si hay empate, continuar en muerte súbita
      } else {
        // En la muerte súbita, solo declarar ganador si la diferencia es de un gol tras ambas ejecuciones
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

  // Obtener el uid del usuario autenticado
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print("Error: Usuario no autenticado");
    return;
  }

  String uid = currentUser.uid;

  // Crear un nuevo documento con los resultados en la subcolección "matches" del usuario
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

  void clearMatrix() {
    playerSelectedTiles.clear();
    cpuSelectedTiles.clear();
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
    });
  }

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

  void cpuSelectSaveZone() {
    setState(() {
      int row = Random().nextInt(3) + 1;
      int col = Random().nextInt(5) + 1;
      cpuSelectedTiles = get3x3Zone(row, col);
    });
  }

  void cpuSelectShootZone() {
    setState(() {
      int row = Random().nextInt(5);
      int col = Random().nextInt(7);
      cpuSelectedTiles = [
        [row, col]
      ];
    });
  }

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

  Color getColorForTile(int row, int col) {
    if (cpuSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
      return Colors.red;
    } else if (playerSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
      return Colors.blue;
    } else if (hoveredTile != null) {
      if (!isPlayerTurn && isInHovered3x3Zone(row, col)) {
        return const Color.fromARGB(255, 91, 195, 107);
      } else if (isPlayerTurn && hoveredTile![0] == row && hoveredTile![1] == col) {
        return const Color.fromARGB(255, 91, 195, 107);
      }
    }
    return Colors.white;
  }

  List<List<int>> getHovered3x3Zone(int row, int col) {
    List<List<int>> hoveredTiles = [];
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;
        if (newRow >= 0 && newRow < 5 && newCol >= 0 && newCol < 7) {
          hoveredTiles.add([newRow, newCol]);
        }
      }
    }
    return hoveredTiles;
  }

  bool isInHovered3x3Zone(int row, int col) {
    if (hoveredTile == null) return false;
    List<List<int>> hoveredArea = getHovered3x3Zone(hoveredTile![0], hoveredTile![1]);
    return hoveredArea.any((tile) => tile[0] == row && tile[1] == col);
  }
}