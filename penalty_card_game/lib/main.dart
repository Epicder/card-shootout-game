import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  MyApp({super.key});
  Future<FirebaseApp> get newMethod => Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check si la conexion con firebase es correcta
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyHomePage();
          }

          // Si hay un error
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text("Error inicializando Firebase"),
              ),
            );
          }

          // Mientras se espera la conexion
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Demo"),
      ),
      body: const Center(
        child: Text("Firebase Initialized Successfully!"),
      ),
    );
  }
}
