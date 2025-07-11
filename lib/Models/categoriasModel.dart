import "package:cloud_firestore/cloud_firestore.dart";
class Categorias {
  final String id;
  final String nombre;
  final String emoji;
  final int orden;
  
  Categorias({required this.id, required this.nombre, required this.emoji, required this.orden});
  
  factory Categorias.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Categorias(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      emoji: (data['emoji'])?? '',
      orden: (data['orden'])?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'emoji': emoji,
    'orden': orden,
  };
}