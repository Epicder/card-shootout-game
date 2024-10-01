import 'models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Todo lo relacionado a el usuario, se crea en esta clase abstracta

abstract class UserRepository {
	Stream<User?> get user; //USER CLASS DE FIREBASE

	Future<MyUser> signUp(MyUser myUser, String password);

	Future<void> setUserData(MyUser user);

	Future<void> signIn(String email, String password);

}