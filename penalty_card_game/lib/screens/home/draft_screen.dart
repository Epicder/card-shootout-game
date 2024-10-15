import 'package:flutter/material.dart';
import 'package:penalty_card_game/screens/home/mvp_screen.dart';


class DraftScreen extends StatelessWidget {
  const DraftScreen({super.key});

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
                'assets/fondo_draft.jpg', // Ruta de la imagen del fondo
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
                'USERNAME F.C',
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
      _playerSlotButton(-0.35, -0.7),
      _playerSlotButton(0.35, -0.7),
      _playerSlotButton(0.0, -0.8),
      _playerSlotButton(-0.20, -0.1),
      _playerSlotButton(0.20, -0.1),
      _playerSlotButton(-0.35, 0.5),
      _playerSlotButton(0.35, 0.5),
      _playerSlotButton(0.0, 0.85),
    ];
  }

  // Widget helper para cada botón de espacio de jugador
  Widget _playerSlotButton(double x, double y) {
    return Align(
      alignment: Alignment(x, y),
      child: ElevatedButton(
        onPressed: () {
          print('Player slot button pressed');
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
