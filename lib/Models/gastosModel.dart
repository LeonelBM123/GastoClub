import "package:cloud_firestore/cloud_firestore.dart";
class Gasto {
  final String id;
  final String categoria;
  final String categoriaId;
  final String descripcion;
  final DateTime fecha;
  final double monto;

  Gasto({
    required this.id,
    required this.categoria,
    required this.categoriaId,
    required this.descripcion,
    required this.fecha,
    required this.monto,
  });

  Future<Map<String, double>> obtenerGastoPorCategoria(String uidUsuario) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidUsuario)
        .collection('gastos')
        .get();

    final Map<String, double> totales = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final categoriaId = data['categoriaId'];
      final cantidad = (data['cantidad'] ?? 0).toDouble();
      totales[categoriaId] = (totales[categoriaId] ?? 0) + cantidad;
    }
    return totales;
  }
  factory Gasto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Gasto(
      id: doc.id,
      categoria: data['categoria'] ?? '',
      categoriaId: data['categoriaId'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      monto: (data['monto'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'categoria': categoria,
        'categoriaId': categoriaId,
        'descripcion': descripcion,
        'fecha': fecha,
        'monto': monto,
      };
}
