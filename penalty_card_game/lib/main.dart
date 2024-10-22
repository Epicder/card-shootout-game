import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:penalty_card_game/app.dart';
import 'firebase_options.dart';
import 'firestore_service.dart';
import 'simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Llamar a la función de carga de jugadores
  //FirestoreService firestoreService = FirestoreService();
  //firestoreService.addMultiplePlayers();

  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp(FirebaseUserRepo()));
}
