import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/src/models/user.dart';
import 'package:user_repository/src/user_repo.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  
  FirebaseUserRepo ({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  // Cuando el usuario hace signIn, este método triggerea
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser;
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
        );
    } catch (errorsignin) {
      log(errorsignin.toString());
      rethrow;
    }
  }

  @override

  // LÓGICA QUE SE TRIGGEREA CUANDO HACÉS EL SIGNUP
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password
      );

      myUser = myUser.copyWith(
        userId: user.user!.uid
      );

      return myUser;

    } catch (errorsignup) {
      log(errorsignup.toString());
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }


  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
        .doc(myUser.userId)
        .set(myUser.toEntity().toDocument()); //convertimos los OBJ user a map porque el set solo acepta maps
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}