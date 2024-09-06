import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(PenaltyShootoutApp());
}

class PenaltyShootoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Penalty Shootout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PenaltyGame(), // Llama a la clase
    );
  }
}

class PenaltyGame extends StatefulWidget {

  @override
  _PenaltyGameState createState() => _PenaltyGameState();
}

class _PenaltyGameState extends State<PenaltyGame> {
  //----VARIABLES----//
  int playerScore = 0;
  int cpuScore = 0;
  bool isPlayerTurn = true;
  List<List<int>> playerSelectedTiles = []; // En esta var se guardan los cuadrados selecionados del usr
  List<List<int>> cpuSelectedTiles = []; // En esta var se guardan los cuadrados selecionados del CPU
  //----VARIABLES----//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Penalty Shootout"),
      ),
      body: Center( // el child column donde se guarda la grid hereda del body Center para que todos los elementos esten centrados
        child: Column( //hijo donde se va a almacenar la grid
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ //TODA LA GRID
          Text(
            "Elián Fc: $playerScore | CPU: $cpuScore",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SizedBox(
              width: 350, 
              height: 250,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, //columnas
                  mainAxisSpacing: 4.0, //espaciado entre filas
                  crossAxisSpacing: 4.0, //espaciado entre columnas
                  childAspectRatio: 1.0, //Para que la grid sean cuadraditos
                ),
                itemCount: 35, //35 cuadraditos selecionables (5x7 = 35)
                itemBuilder: (context, index) {
                  int row = index ~/ 7; // Calculate row from index
                  int col = index % 7;  // Calculate column from index

                  return GestureDetector( // checkear el estado del bool playerturn para saber si el usr ataja o patea
                    onTap: () {
                      if (isPlayerTurn) {
                        handlePlayerShoot(row, col); //si es el turno del player, llama a la funcion para patear
                      } else {
                        handlePlayerSave(row, col); //si es false, por ende el player ataja
                      }
                    },
                    child: GridTile( // Estilo de cada cuadrado
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: getColorForTile(row, col),
                          border: Border.all(color: Colors.black),
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


  //----LOGICA DE PATEAR PLAYER----//
  void handlePlayerShoot(int row, int col) {
    setState(() {
      playerSelectedTiles = [
        [row, col]
      ];
      // una vez guarda los valores en pselectedtiles, llama a la f para que la cpu ataje random y la que compara para ver si es gol
      cpuSelectSaveZone();
      checkGoalOrSave();
      isPlayerTurn = false; // cambia el bool a false para cambiar de posicion
    });
  }

  //----LOGICA DE PATEAR PLAYER----//
  void handlePlayerSave(int row, int col) {
    if (row < 4 && col < 6) { // gracias chatgpt por ayudarme con la logica para atajar en 2x2 
      setState(() {
        playerSelectedTiles = [
          [row, col],
          [row + 1, col],
          [row, col + 1],
          [row + 1, col + 1]
        ];
        // lo mismo que cuando pateas pero a la inversa
        cpuSelectShootZone();
        checkGoalOrSave();
        isPlayerTurn = true;
      });
    }
  }

  //----LOGICA CPU ATAJAR----//
  void cpuSelectSaveZone() {
    setState(() {
      cpuSelectedTiles = getRandom2x2Zone();
    });
  }

  //----CPU 2X2 RANDOM----// (chatgpt, hay que revisar)
  List<List<int>> getRandom2x2Zone() {
    int row = Random().nextInt(4); // Limit to 4 to stay within bounds
    int col = Random().nextInt(6); // Limit to 6 to stay within bounds
    return [
      [row, col],
      [row + 1, col],
      [row, col + 1],
      [row + 1, col + 1]
    ];
  }

  //----LOGICA DE PATEO CPU----//
  void cpuSelectShootZone() {
    setState(() {
      int row = Random().nextInt(5); // Random() para elegir coords al azar en una de las 5 filas
      int col = Random().nextInt(7); // Random() para elegir coords al azar en una de las 7 columnas
      cpuSelectedTiles = [
        [row, col]
      ];
    });
  }

  //----COMPROBACIONES PARA VER SI ES GOL----//
  void checkGoalOrSave() {
    if (isPlayerTurn) { //si es el turno del usr, se comprueba si mete gol, si sí, incrementa la var playerscore
      if (cpuSelectedTiles.any((tile) => tile[0] == playerSelectedTiles[0][0] && tile[1] == playerSelectedTiles[0][1])) {
        print("CPU atajo");
      } else {
        playerScore++;
        print("USR gol");
      }
    } else {
      //si es el turno de patear de la cpu, se comprueba si mete gol, si sí, incrementa la var playerscore
      if (playerSelectedTiles.any((tile) => tile[0] == cpuSelectedTiles[0][0] && tile[1] == cpuSelectedTiles[0][1])) {
        print("USR atajo");
      } else {
        cpuScore++;
        print("CPU gol");
      }
    }
  }
  // Diferenciar al usr con la cpu
  Color getColorForTile(int row, int col) {
    if (playerSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
      return Colors.blue; //toma los tiles seleccionados por el usr y los pone de azul
    } else if (cpuSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
      return Colors.red; //toma los tiles seleccionados por el CPU y los pone de rojo
    } else {
      return Colors.white; //si los tiles no estan seleccionados por ni el cpu ni el usr, son blancos
    }
  }
}