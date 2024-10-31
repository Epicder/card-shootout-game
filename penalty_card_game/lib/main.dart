import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:user_repository/user_repository.dart';
import 'package:penalty_card_game/app.dart';
import 'firebase_options.dart';
import 'firestore_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Llamar a la función de carga de jugadores
  //FirestoreService firestoreService = FirestoreService(); // Ya no se necesita, ya estan los jugadores en la base de datos, iniciar solo si se necesita agregar jugadores
  //firestoreService.addMultiplePlayers();
  runApp(MyApp(FirebaseUserRepo()));
}
