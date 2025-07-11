import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastoclub/mobile/auth_service.dart';
import 'package:flutter/services.dart'; // <-- Importa services.dart para el portapapeles
// Asegúrate de tener tus imports de paleta de colores y servicios de autenticación
import 'package:gastoclub/pallete.dart';
import 'package:intl/intl.dart';

class Club extends StatefulWidget {
  const Club({super.key});

  @override
  State<Club> createState() => _ClubState();
}

class _ClubState extends State<Club> {
  // Asumimos que tienes acceso al uid del usuario
  final String? uid = authService.value.getCurrentUser()?.uid;

  // Stream para obtener los grupos del usuario en tiempo real
  Stream<QuerySnapshot>? _groupsStream;

  @override
  void initState() {
    super.initState();
    if (uid != null) {
      _groupsStream =
          FirebaseFirestore.instance
              .collection('groups')
              .where('memberIds', arrayContains: uid)
              .snapshots();
    }
  }

  // Pega esta función dentro de la clase _ClubState
  Future<void> _createGroup(String name, String ownerId) async {
    try {
      await FirebaseFirestore.instance.collection('groups').add({
        'name': name,
        'ownerId': ownerId,
        'memberIds': [ownerId], // El creador es el primer miembro
        'creationDate': Timestamp.now(), // <-- LÍNEA AÑADIDA
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Club creado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el club: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _joinGroup(String groupId, String userId) async {
    try {
      final groupRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId);

      // Verifica si el grupo existe
      final doc = await groupRef.get();
      if (!doc.exists) {
        throw Exception('El club no existe.');
      }

      await groupRef.update({
        'memberIds': FieldValue.arrayUnion([
          userId,
        ]), // Añade el usuario sin duplicar
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Te has unido al club!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al unirse: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget para la pestaña de "Crear"
  Widget _buildCreateTab(
    GlobalKey<FormState> key,
    TextEditingController controller,
    String uid,
  ) {
    return Form(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nombre del Club',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colores.paleta[2]),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4EF037)),
              ),
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Ingresa un nombre' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                _createGroup(controller.text, uid);
                Navigator.pop(context); // Cierra el diálogo
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colores.paleta[2]),
            child: const Text('Crear Club'),
          ),
        ],
      ),
    );
  }

  // Widget para la pestaña de "Unirse"
  Widget _buildJoinTab(
    GlobalKey<FormState> key,
    TextEditingController controller,
    String uid,
  ) {
    return Form(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'ID del Club',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colores.paleta[2]),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4EF037)),
              ),
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Ingresa un ID' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                _joinGroup(controller.text, uid);
                Navigator.pop(context); // Cierra el diálogo
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colores.paleta[2]),
            child: const Text('Unirse al Club'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Center(child: Text('Inicia sesión para ver tus clubes.'));
    }

    return Scaffold(
      backgroundColor: Colores.paleta[0],
      appBar: AppBar(
        title: const Text(
          'Mis Clubes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colores.paleta[0],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _groupsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No perteneces a ningún club.\n¡Crea o únete a uno!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final groups = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupName = group['name'] as String;
              final memberCount = (group['memberIds'] as List).length;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colores.paleta[1],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4EF037),
                    child: Icon(Icons.groups, color: Colors.white),
                  ),
                  title: Text(
                    groupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '$memberCount Miembros',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailsScreen(groupId: group.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // Dentro del build de tu widget Club
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Llama al nuevo diálogo de una forma más limpia
          showDialog(
            context: context,
            builder: (context) => CreateOrJoinDialog(uid: uid!),
          );
        },
        label: const Text('Añadir Club'),
        icon: const Icon(Icons.add),
        backgroundColor: Colores.paleta[2],
      ),
    );
  }
}

// Puedes poner esta nueva clase al final de tu archivo
class CreateOrJoinDialog extends StatefulWidget {
  final String uid;
  const CreateOrJoinDialog({super.key, required this.uid});

  @override
  State<CreateOrJoinDialog> createState() => _CreateOrJoinDialogState();
}

class _CreateOrJoinDialogState extends State<CreateOrJoinDialog> {
  final _createController = TextEditingController();
  final _joinController = TextEditingController();
  final _formKeyCreate = GlobalKey<FormState>();
  final _formKeyJoin = GlobalKey<FormState>();

  // Es importante liberar los controladores para evitar fugas de memoria
  @override
  void dispose() {
    _createController.dispose();
    _joinController.dispose();
    super.dispose();
  }

  Future<void> _createGroup(String name) async {
    try {
      await FirebaseFirestore.instance.collection('groups').add({
        'name': name,
        'ownerId': widget.uid,
        'memberIds': [widget.uid],
      });
      Navigator.pop(context); // Cierra el diálogo solo si tiene éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Club creado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el club: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _joinGroup(String groupId) async {
    try {
      final groupRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId.trim());
      final doc = await groupRef.get();
      if (!doc.exists) throw Exception('El club no existe.');

      await groupRef.update({
        'memberIds': FieldValue.arrayUnion([widget.uid]),
      });
      Navigator.pop(context); // Cierra el diálogo solo si tiene éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Te has unido al club!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al unirse: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colores.paleta[0],
      title: const Text(
        'Crear o Unirse a un Club',
        style: TextStyle(color: Colors.white),
      ),
      // Envolvemos el contenido en un DefaultTabController
      content: DefaultTabController(
        length: 2,
        child: SizedBox(
          width: double.maxFinite,
          // Limitamos la altura para evitar el congelamiento
          height: 200,
          child: Column(
            children: [
              const TabBar(
                tabs: [Tab(text: 'Crear'), Tab(text: 'Unirse')],
                labelColor: Colors.white,
                indicatorColor: Color(0xFF4EF037),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Pestaña Crear
                    _buildTabContent(
                      key: _formKeyCreate,
                      controller: _createController,
                      labelText: 'Nombre del Club',
                      buttonText: 'Crear Club',
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Ingresa un nombre'
                                  : null,
                      onPressed: () {
                        if (_formKeyCreate.currentState!.validate()) {
                          _createGroup(_createController.text);
                        }
                      },
                    ),
                    // Pestaña Unirse
                    _buildTabContent(
                      key: _formKeyJoin,
                      controller: _joinController,
                      labelText: 'ID del Club',
                      buttonText: 'Unirse al Club',
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Ingresa un ID'
                                  : null,
                      onPressed: () {
                        if (_formKeyJoin.currentState!.validate()) {
                          _joinGroup(_joinController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para el contenido de cada pestaña
  Widget _buildTabContent({
    required GlobalKey<FormState> key,
    required TextEditingController controller,
    required String labelText,
    required String buttonText,
    required String? Function(String?) validator,
    required VoidCallback onPressed,
  }) {
    return Form(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colores.paleta[2]),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4EF037)),
              ),
            ),
            validator: validator,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: Colores.paleta[2]),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}


// Asumo que tienes un modelo 'Gasto' para consistencia. Si no, puedes quitarlo.
// import 'package:gastoclub/models/gasto.dart'; 

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late Future<DocumentSnapshot> _groupDetailsFuture;

  @override
  void initState() {
    super.initState();
    _groupDetailsFuture = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();
  }

  /// Convierte de forma segura un valor a double, sin importar si es
  /// un número, un string o nulo.
  double _parseMonto(dynamic montoValue) {
    if (montoValue == null) return 0.0;
    if (montoValue is num) return montoValue.toDouble();
    if (montoValue is String) return double.tryParse(montoValue) ?? 0.0;
    return 0.0;
  }

  /// Calcula el total de gastos de todos los miembros desde la fecha de creación del grupo.
  Future<double> _calcularTotalGastos(List<dynamic> memberIds, DateTime creationDate) async {
    double totalGeneral = 0;
    final List<Future<QuerySnapshot>> futures = [];

    for (String memberId in memberIds) {
      futures.add(FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .collection('gastos')
          .where('fecha', isGreaterThanOrEqualTo: creationDate)
          .get());
    }

    final List<QuerySnapshot> results = await Future.wait(futures);
    for (var userGastosSnapshot in results) {
      for (var doc in userGastosSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalGeneral += _parseMonto(data['monto']);
      }
    }
    return totalGeneral;
  }

  /// Obtiene los 10 gastos más recientes de todos los miembros del grupo.
  Future<List<QueryDocumentSnapshot>> _getRecentExpenses(List<dynamic> memberIds, DateTime creationDate) async {
    final List<QueryDocumentSnapshot> todosLosGastos = [];
    final List<Future<QuerySnapshot>> futures = [];

    for (String memberId in memberIds) {
      futures.add(FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .collection('gastos')
          .where('fecha', isGreaterThanOrEqualTo: creationDate)
          .orderBy('fecha', descending: true)
          .limit(10)
          .get());
    }

    final List<QuerySnapshot> results = await Future.wait(futures);
    for (var userGastosSnapshot in results) {
      todosLosGastos.addAll(userGastosSnapshot.docs);
    }

    todosLosGastos.sort((a, b) {
      final fechaA = (a.data() as Map)['fecha'] as Timestamp;
      final fechaB = (b.data() as Map)['fecha'] as Timestamp;
      return fechaB.compareTo(fechaA);
    });

    return todosLosGastos.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.paleta[0],
      appBar: AppBar(
        backgroundColor: Colores.paleta[1],
        title: FutureBuilder<DocumentSnapshot>(
          future: _groupDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      data?['name'] ?? 'Detalles del Club',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20, color: Colors.white54),
                    tooltip: 'Copiar ID',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: widget.groupId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID copiado al portapapeles')),
                      );
                    },
                  ),
                ],
              );
            }
            return const Text('Cargando...');
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _groupDetailsFuture,
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
            return const Center(child: Text('No se pudo cargar el grupo.', style: TextStyle(color: Colors.white)));
          }

          final groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
          final memberIds = groupData['memberIds'] as List;
          final creationDate = (groupData['creationDate'] as Timestamp?)?.toDate() ?? DateTime(1970);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card con el total de gastos
                FutureBuilder<double>(
                  future: _calcularTotalGastos(memberIds, creationDate),
                  builder: (context, totalSnapshot) {
                    Widget content;
                    if (totalSnapshot.connectionState == ConnectionState.waiting) {
                      content = const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                    } else {
                      final total = totalSnapshot.data ?? 0;
                      content = Column(
                        children: [
                          const Text('Total Gastado (Miembros)', style: TextStyle(color: Colors.white70, fontSize: 18)),
                          const SizedBox(height: 10),
                          Text(
                            '${total.toStringAsFixed(2)} Bs',
                            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }
                    return Card(
                      color: Colores.paleta[2],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(padding: const EdgeInsets.all(24.0), child: content),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text('Últimos Gastos del Club', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 20),
                
                // Lista con los últimos gastos
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _getRecentExpenses(memberIds, creationDate),
                  builder: (context, gastosSnapshot) {
                    if (gastosSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!gastosSnapshot.hasData || gastosSnapshot.data!.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No hay gastos para mostrar.', style: TextStyle(color: Colors.white70)),
                      ));
                    }
                    final gastos = gastosSnapshot.data!;
                    return ListView.builder(
                      itemCount: gastos.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final gasto = gastos[index].data() as Map<String, dynamic>;
                        final fecha = (gasto['fecha'] as Timestamp).toDate();
                        return ListTile(
                          leading: const Icon(Icons.receipt_long, color: Color(0xFF4EF037)),
                          title: Text(gasto['descripcion'] ?? 'Gasto sin descripción', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          subtitle: Text(DateFormat('d MMMM, yyyy', 'es').format(fecha), style: const TextStyle(color: Colors.white54)),
                          trailing: Text('${_parseMonto(gasto['monto']).toStringAsFixed(2)} Bs', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}