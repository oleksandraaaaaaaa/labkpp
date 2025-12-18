import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; 

// Оголошення класу, що інкапсулює логіку автентифікації.
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp({required String email, required String password}) async {
    // для створення нового користувача з email та паролем.
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Невідома помилка реєстрації.";
    }
  }

  
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Невірна пошта або пароль.";
    }
  }
  // Потік (Stream) для відстеження стану авторизації (входу/виходу) в реальному часі.
  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}