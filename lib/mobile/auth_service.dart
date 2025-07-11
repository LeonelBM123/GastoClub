import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:gastoclub/Models/categoriasModel.dart';
import 'package:gastoclub/Models/gastosModel.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
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
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      //Capturo el id del Usuario
      String uid = userCredential.user!.uid;
      //Guardo la informacion
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'registroFechaHora': FieldValue.serverTimestamp(),
        'groupId': [],
      });
      //Genero las categorias por default
      final categorias = [
        {'nombre': 'Comida', 'color': 'rojo', 'emoji':'🍔', 'orden': 1},
        {'nombre': 'Transporte', 'color': 'verde', 'emoji':'🚌', 'orden': 2},
        {'nombre': 'Entretenimiento', 'color': 'naranja', 'emoji':'🎯', 'orden': 3},
        {'nombre': 'Salud', 'color': 'azul', 'emoji':'🧪', 'orden': 4},
        {'nombre': 'Educacion', 'color': 'gris', 'emoji':'📚', 'orden': 5},
        {'nombre': 'Otros', 'color': 'violeta', 'emoji':'🔮', 'orden': 6}
      ];

      final batch = FirebaseFirestore.instance.batch();
      final categoriasRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('categorias');
      for (final categoria in categorias) {
        final docRef = categoriasRef.doc(); // genera ID automático
        batch.set(docRef, {
          'nombre': categoria['nombre'],
          'color': categoria['color'],
          'emoji': categoria['emoji'],
          'orden': categoria['orden'],
          'creadoEn': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      return userCredential.user;
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }
  //getCategorias
  Future<List<Categorias>> getCategorias(String uid)async{
    final docsCategorias= await FirebaseFirestore.instance.collection('users').doc(uid).collection('categorias').get();
    return docsCategorias.docs
      .map((doc) => Categorias.fromFirestore(doc))
      .toList();
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Save Spensive
  Future<bool> saveGasto() async {
    try {
      //Capturo el id del Usuario
      String uid = getCurrentUser()!.uid;
      //Guardo la informacion
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('gastos')
          .add({
            'monto': 100,
            'categoria': 'Comida',
            'fecha': FieldValue.serverTimestamp(),
            'descripcion': 'Almuerzo',
          });
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<String?> getPrimerNombre(String uid) async {
    
    final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      // Suponiendo que el campo se llama 'nombre' y es un String
      return data['name']?.split(' ').first;
    } else {
      return null; // O lanza una excepción si prefieres
    }
  }

    Future<String?> getNombre(String uid) async {
    
    final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      // Suponiendo que el campo se llama 'nombre' y es un String
      return data['name'];
    } else {
      return null; // O lanza una excepción si prefieres
    }
  }
  Future<List<Gasto>> obtenerUltimos5Gastos(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('gastos')
        .orderBy('fecha', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => Gasto.fromFirestore(doc)).toList();
  }
}
