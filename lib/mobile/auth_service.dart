import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //Capturo el id del Usuario
      String uid = userCredential.user!.uid;
      //Guardo la informacion
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'name':  name,
      'registroFechaHora': FieldValue.serverTimestamp(),
    });
      return userCredential.user;
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
