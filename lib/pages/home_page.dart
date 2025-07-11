import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gastoclub/Models/categoriasModel.dart';
import 'package:gastoclub/Models/gastosModel.dart';
import 'package:gastoclub/mobile/auth_service.dart';
import 'package:gastoclub/pallete.dart';
import 'package:intl/intl.dart'; // No olvides este import
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  //
  void _eliminarGasto(String gastoId) async {
    // Asegúrate de tener acceso al 'uid' del usuario aquí
    final uid =
        authService.value.getCurrentUser()?.uid; // O como obtengas el uid
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('gastos')
          .doc(gastoId)
          .delete();

      // Opcional: Muestra una confirmación si lo deseas
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar el gasto: $e')));
    }
  }

  //
  Widget build(BuildContext context) {
    final uid = authService.value.getCurrentUser()?.uid;
    if (uid == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }
    Future<String?> nombre = authService.value.getPrimerNombre(uid);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colores.paleta[0],
        appBar: AppBar(
          backgroundColor: Colores.paleta[0],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                child: FutureBuilder<String?>(
                  future: authService.value.getPrimerNombre(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final primernombre = snapshot.data;
                    return Text(
                      primernombre != null
                          ? 'Hola, $primernombre!'
                          : 'Hola usuario!',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    );
                  },
                ),
              ),
              Container(
                child: const Text(
                  '  Aquí está tu resumen financiero',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(145, 208, 208, 208),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              // 1. MARCA LA FUNCIÓN COMO ASYNC
              onPressed: () async {
                final uid = authService.value.getCurrentUser()?.uid;

                if (uid != null) {
                  // 2. OBTÉN LAS CATEGORÍAS ANTES DE MOSTRAR EL DIÁLOGO
                  final List<Categorias> misCategorias = await authService.value
                      .getCategorias(uid);

                  // (Buena práctica) Verifica que el widget todavía esté en pantalla
                  if (!context.mounted) return;

                  // 3. AHORA SÍ, MUESTRA EL DIÁLOGO CON LOS DATOS YA LISTOS
                  showDialog(
                    context: context,
                    builder:
                        (context) => GastosDonutChartDialog(
                          uid: uid,
                          categorias:
                              misCategorias, // 4. Pasa la lista que ya obtuviste
                        ),
                  );
                }
              },
              icon: const Icon(Icons.data_usage),
              iconSize: 35,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  StateCard(),
                  SizedBox(height: 20),
                  Text(
                    'Categorias Principales',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 300,
                    height: 250,
                    child: ListaCategoriasWidget(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Gastos Recientes',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('gastos')
                            .orderBy('fecha', descending: true)
                            .limit(5)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No hay gastos recientes.'));
                      }

                      final gastos =
                          snapshot.data!.docs
                              .map((doc) => Gasto.fromFirestore(doc))
                              .toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: gastos.length,
                        itemBuilder: (context, index) {
                          final gasto = gastos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                            color: const Color(0xFF232B45),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colores.paleta[0],
                                child: Text(
                                  gasto
                                      .categoria
                                      .characters
                                      .first, // primer letra o emoji
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              title: Text(
                                gasto.categoria,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              subtitle:
                                  gasto.descripcion.isEmpty
                                      ? null
                                      : Text(
                                        gasto.descripcion,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize
                                        .min, // Esto hace que la fila ocupe solo lo necesario.
                                children: [
                                  // 1. El texto con el monto (como lo tenías antes)
                                  Text(
                                    "${gasto.monto.toStringAsFixed(2)} Bs",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4EF037),
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ), // 2. Un espacio para separar
                                  // 3. El nuevo botón para eliminar
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      // Muestra el diálogo de confirmación con el nuevo estilo
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            // --- ESTILOS APLICADOS ---
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            backgroundColor:
                                                Colores
                                                    .paleta[0], // Color de fondo oscuro
                                            title: const Text(
                                              'Confirmar eliminación',
                                              style: TextStyle(
                                                color:
                                                    Colors
                                                        .white, // Color de texto del título
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: const Text(
                                              '¿Estás seguro de que quieres eliminar este gasto?',
                                              style: TextStyle(
                                                color:
                                                    Colors
                                                        .white70, // Color de texto del contenido
                                                fontSize: 18,
                                              ),
                                            ),
                                            actions: <Widget>[
                                              // Botón "Cancelar"
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  // Estilo para el botón de cancelar (puedes ajustarlo)
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    side: BorderSide(
                                                      color: Colores.paleta[2],
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              // Botón "Eliminar"
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  // Estilo para el botón principal de acción
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colores.paleta[2],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text('Eliminar'),
                                                onPressed: () {
                                                  _eliminarGasto(gasto.id);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // --- SECCIÓN DE CONSEJO IA ---
                  // Reemplaza 'AQUI_TU_API_KEY' por tu clave real de OpenRouter:
                  GeminiAdviceSection(uid: uid, openRouterApiKey: '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'),
                  // --- FIN SECCIÓN DE CONSEJO IA ---
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ListaCategoriasWidget extends StatelessWidget {
  const ListaCategoriasWidget({super.key});

  Future<Map<String, double>> obtenerGastoPorCategoria(
    String uidUsuario,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uidUsuario)
            .collection('gastos')
            .get();

    final Map<String, double> totales = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final categoriaId = data['categoriaId'];
      final cantidad = (data['monto'] ?? 0).toDouble();
      totales[categoriaId] = (totales[categoriaId] ?? 0) + cantidad;
    }

    return totales;
  }

  @override
  Widget build(BuildContext context) {
    final uid = authService.value.getCurrentUser()?.uid;

    if (uid == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return FutureBuilder(
      future: Future.wait([
        authService.value.getCategorias(uid),
        obtenerGastoPorCategoria(uid),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar datos'));
        }

        final categorias = snapshot.data![0] as List<Categorias>;
        final totalesPorCategoria = snapshot.data![1] as Map<String, double>;

        if (categorias.isEmpty) {
          return const Center(child: Text('No hay categorías disponibles'));
        }

        categorias.sort((a, b) => a.orden.compareTo(b.orden));

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          padding: const EdgeInsets.all(10),
          children:
              categorias.map((cat) {
                final cantidadGastada = totalesPorCategoria[cat.id] ?? 0.0;
                return Categoria(
                  categoria: cat,
                  //cantidadGastada: cantidadGastada,
                );
              }).toList(),
        );
      },
    );
  }
}

class Categoria extends StatelessWidget {
  final Categorias categoria;

  const Categoria({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final uid = authService.value.getCurrentUser()?.uid;

    if (uid == null) {
      return const SizedBox.shrink(); // Manejo seguro si no hay usuario
    }

    // Rango de fechas: todo el mes actual
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Stream solo de los gastos de esta categoría en el mes actual
    final stream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('gastos')
            .where('categoriaId', isEqualTo: categoria.id)
            .where(
              'fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay),
            )
            .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
            .snapshots();

    return GestureDetector(
      onTap: () {
        // --- CAMBIO PRINCIPAL AQUÍ ---
        // Ahora llamamos a nuestro nuevo diálogo detallado
        showDialog(
          context: context,
          builder: (context) {
            return GastosPorCategoriaDialog(
              uid: uid,
              categoria: categoria,
              firstDay: firstDay,
              lastDay: lastDay,
            );
          },
        );
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          double total = 0;

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              total += (data['monto'] as num?)?.toDouble() ?? 0;
            }
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colores.paleta[1],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(categoria.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 4),
                  Text(
                    categoria.nombre,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 153, 201, 255),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class StateCard extends StatelessWidget {
  const StateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.value.getCurrentUser()?.uid;
    if (uid == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    // Obtén el primer y último día del mes actual
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('gastos')
              .where(
                'fecha',
                isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay),
              )
              .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
              .snapshots(),
      builder: (context, snapshot) {
        double totalMes = 0.0;

        if (snapshot.hasData) {
          final gastos = snapshot.data!.docs;
          for (var doc in gastos) {
            final data = doc.data() as Map<String, dynamic>;
            totalMes += (data['monto'] as num?)?.toDouble() ?? 0.0;
          }
        }

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colores.paleta[1],
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colores.paleta[1], // Color de la sombra
                offset: Offset(4, 4), // Desplazamiento X e Y
                blurRadius: 10, // Desenfoque
                spreadRadius: 0, // Expansión
              ),
            ],
          ),
          height: 150,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Gastos este mes:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color.fromARGB(154, 238, 238, 238),
                    ),
                  ),
                  Text(
                    "${totalMes.toStringAsFixed(2)} Bs",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.arrow_outward,
                            size: 15,
                            color: Colors.green,
                          ),
                        ),
                        TextSpan(
                          text: "+12% vs el anterior mes",
                          style: TextStyle(fontSize: 15, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.add, size: 40),
                    onPressed: () async {
                      final categorias = await authService.value.getCategorias(
                        authService.value.getCurrentUser()!.uid,
                      );
                      String? categoriaSeleccionadaId;
                      double? monto;
                      String descripcion = '';
                      showModalBottomSheet(
                        backgroundColor: Colores.paleta[1],
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setModalState) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                      24,
                                  top: 32,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Añadir Gasto',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    // Selector de categorías
                                    SizedBox(
                                      height: 70,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categorias.length,
                                        separatorBuilder:
                                            (_, __) => SizedBox(width: 10),
                                        itemBuilder: (context, idx) {
                                          final cat = categorias[idx];
                                          final isSelected =
                                              cat.id == categoriaSeleccionadaId;
                                          return GestureDetector(
                                            onTap: () {
                                              setModalState(
                                                () =>
                                                    categoriaSeleccionadaId =
                                                        cat.id,
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 150,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isSelected
                                                        ? Colores.paleta[2]
                                                        : Colores.paleta[0],
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    cat.emoji,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    cat.nombre,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 18),
                                    // Campo de monto
                                    TextField(
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: InputDecoration(
                                        labelText: 'Monto',
                                        prefixIcon: Icon(Icons.attach_money),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          monto = double.tryParse(value);
                                        });
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    // Campo de descripción (opcional)
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Descripción (opcional)',
                                        prefixIcon: Icon(
                                          Icons.edit_note_outlined,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          descripcion = value;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 24),
                                    // Botón guardar
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.check),
                                      label: Text('Guardar'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          (monto == null ||
                                                  monto! <= 0 ||
                                                  categoriaSeleccionadaId ==
                                                      null)
                                              ? null
                                              : () async {
                                                // Aquí guardas el gasto en Firestore
                                                final cat = categorias.firstWhere(
                                                  (c) =>
                                                      c.id ==
                                                      categoriaSeleccionadaId,
                                                );
                                                final uid =
                                                    authService.value
                                                        .getCurrentUser()!
                                                        .uid;
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(uid)
                                                    .collection('gastos')
                                                    .add({
                                                      'monto': monto,
                                                      'descripcion':
                                                          descripcion,
                                                      'categoria': cat.nombre,
                                                      'categoriaId': cat.id,
                                                      'fecha': DateTime.now(),
                                                    });
                                                Navigator.pop(context);
                                              },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  Text(
                    "Añadir gasto",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class GastosPorCategoriaDialog extends StatefulWidget {
  // 1. Cambia a StatefulWidget
  final String uid;
  final Categorias categoria;
  final DateTime firstDay;
  final DateTime lastDay;

  const GastosPorCategoriaDialog({
    super.key,
    required this.uid,
    required this.categoria,
    required this.firstDay,
    required this.lastDay,
  });

  @override
  State<GastosPorCategoriaDialog> createState() =>
      _GastosPorCategoriaDialogState();
}

class _GastosPorCategoriaDialogState extends State<GastosPorCategoriaDialog> {
  // 2. Define la variable del stream aquí
  late final Stream<QuerySnapshot> _gastosStream;

  @override
  void initState() {
    super.initState();
    // 3. Inicializa el stream UNA SOLA VEZ en initState
    _gastosStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid) // Usa 'widget.' para acceder a las propiedades
            .collection('gastos')
            .where('categoriaId', isEqualTo: widget.categoria.id)
            .where(
              'fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(widget.firstDay),
            )
            .where(
              'fecha',
              isLessThanOrEqualTo: Timestamp.fromDate(widget.lastDay),
            )
            .orderBy('fecha', descending: true)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colores.paleta[0],
      title: Row(
        children: [
          Text(widget.categoria.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 8),
          Text(
            widget.categoria.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream:
              _gastosStream, // 4. Usa la variable del stream definida en el estado
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No hay gastos en esta categoría para el mes actual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final gastos =
                snapshot.data!.docs
                    .map((doc) => Gasto.fromFirestore(doc))
                    .toList();

            return ListView.builder(
              shrinkWrap: true,
              itemCount: gastos.length,
              itemBuilder: (context, index) {
                final gasto = gastos[index];
                return ListTile(
                  title: Text(
                    gasto.descripcion.isEmpty
                        ? 'Gasto sin descripción'
                        : gasto.descripcion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('EEEE, d \'de\' MMMM', 'es').format(gasto.fecha),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: Text(
                    '${gasto.monto.toStringAsFixed(2)} Bs',
                    style: const TextStyle(
                      color: Color(0xFF4EF037),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colores.paleta[2],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class GastosDonutChartDialog extends StatefulWidget {
  final String uid;
  final List<Categorias> categorias;

  const GastosDonutChartDialog({
    super.key,
    required this.uid,
    required this.categorias,
  });

  @override
  State<GastosDonutChartDialog> createState() => _GastosDonutChartDialogState();
}

class _GastosDonutChartDialogState extends State<GastosDonutChartDialog> {
  // 1. Un Future para cada cálculo
  late Future<Map<String, double>> _gastosPorCategoriaFuture;
  late Future<Map<String, double>> _gastosPorMesFuture;

  @override
  void initState() {
    super.initState();
    // Inicializamos ambos futures
    _gastosPorCategoriaFuture = _calcularGastosPorCategoria();
    _gastosPorMesFuture = _calcularGastosPorMes();
  }

  // Función para el gráfico de dona (sin cambios)
  Future<Map<String, double>> _calcularGastosPorCategoria() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('gastos')
            .get();
    final Map<String, double> gastosAgrupados = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      gastosAgrupados.update(
        data['categoriaId'],
        (value) => value + (data['monto'] as num),
        ifAbsent: () => (data['monto'] as num).toDouble(),
      );
    }
    return gastosAgrupados;
  }

  // 2. NUEVA FUNCIÓN para la lista de gastos mensuales
  Future<Map<String, double>> _calcularGastosPorMes() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('gastos')
            .orderBy(
              'fecha',
              descending: true,
            ) // Ordenamos para que el mapa se genere ordenado
            .get();

    final Map<String, double> gastosMensuales = {};
    final format = DateFormat('MMMM yyyy', 'es'); // Formato "julio 2025"

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final fecha = (data['fecha'] as Timestamp).toDate();
      final monto = (data['monto'] as num).toDouble();
      final mesKey = format.format(fecha);

      // Agrupa y suma los montos por clave de mes
      gastosMensuales.update(
        mesKey,
        (value) => value + monto,
        ifAbsent: () => monto,
      );
    }
    return gastosMensuales;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colores.paleta[0],
      title: const Text(
        'Resumen de Gastos',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // 3. El contenido ahora es una Columna para alojar ambos widgets
      content: SizedBox(
        width: double.maxFinite,
        height: 500, // Aumentamos la altura para dar espacio a la lista
        child: Column(
          children: [
            // --- GRÁFICO DE DONA (SIN CAMBIOS) ---
            SizedBox(
              height: 250, // Altura fija para el gráfico
              child: FutureBuilder<Map<String, double>>(
                future: _gastosPorCategoriaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay datos para el gráfico',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  final gastosData = snapshot.data!;
                  final totalGastado = gastosData.values.reduce(
                    (a, b) => a + b,
                  );
                  List<PieChartSectionData> sections =
                      gastosData.entries.map((entry) {
                        final categoriaInfo = widget.categorias.firstWhere(
                          (c) => c.id == entry.key,
                          orElse:
                              () => Categorias(
                                id: '',
                                nombre: 'Otro',
                                emoji: '❓',
                                orden: 99,
                              ),
                        );
                        return PieChartSectionData(
                          color:
                              Colors.primaries[widget.categorias.indexOf(
                                    categoriaInfo,
                                  ) %
                                  Colors.primaries.length],
                          value: entry.value,
                          title:
                              '${(entry.value / totalGastado * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 2),
                            ], // Sombra para legibilidad
                          ),
                          // --- LÍNEAS AÑADIDAS ---
                          badgeWidget: Text(
                            categoriaInfo.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          badgePositionPercentageOffset: .98,
                          // --- FIN DE LÍNEAS AÑADIDAS ---
                        );
                      }).toList();
                  return PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white24),
            const Text(
              'Totales por Mes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // --- NUEVA LISTA DE GASTOS MENSUALES ---
            Expanded(
              child: FutureBuilder<Map<String, double>>(
                future: _gastosPorMesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay gastos registrados',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  final gastosMensuales = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: gastosMensuales.length,
                    itemBuilder: (context, index) {
                      final mes = gastosMensuales.keys.elementAt(index);
                      final total = gastosMensuales.values.elementAt(index);
                      return ListTile(
                        title: Text(
                          mes[0].toUpperCase() +
                              mes.substring(
                                1,
                              ), // Pone la primera letra en mayúscula
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Text(
                          '${total.toStringAsFixed(2)} Bs',
                          style: const TextStyle(
                            color: Color(0xFF4EF037),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

// --- Widget de Consejos con Gemini AI ---
class GeminiAdviceSection extends StatefulWidget {
  final String uid;
  // PON AQUÍ TU API KEY DE OPENROUTER:
  // Ejemplo: final String openRouterApiKey = 'sk-...';
  final String openRouterApiKey;
  const GeminiAdviceSection({
    super.key,
    required this.uid,
    required this.openRouterApiKey, // <-- Coloca tu API KEY aquí al instanciar el widget
  });

  @override
  State<GeminiAdviceSection> createState() => _GeminiAdviceSectionState();
}

class _GeminiAdviceSectionState extends State<GeminiAdviceSection> {
  String? _advice;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getAdvice();
  }

  Future<Map<String, double>> _getMonthlyExpenses() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('gastos')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .get();
    Map<String, double> porCategoria = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final monto = (data['monto'] as num?)?.toDouble() ?? 0.0;
      final categoria = data['categoria'] ?? 'Otro';
      porCategoria[categoria] = (porCategoria[categoria] ?? 0) + monto;
    }
    return porCategoria;
  }

  Future<void> _getAdvice() async {
    setState(() {
      _loading = true;
      _advice = null;
    });
    final gastos = await _getMonthlyExpenses();
    final total = gastos.values.fold(0.0, (a, b) => a + b);
    final prompt = """
Eres un asesor financiero personal. Analiza los siguientes gastos mensuales del usuario (por categoría y total) y da un consejo breve y útil para mejorar sus finanzas personales. Sé empático y concreto.
Ten en cuenta que los usuarios seran de Bolivia-Santa Cruz.
Da el consejo directamente, basandote en los gastos y en donde podria ahorrar un poco más.
Tus consejos deben ser puntuales, que no pasen de las 60 palabras.
Gastos por categoría este mes:
${gastos.entries.map((e) => '- ${e.key}: ${e.value.toStringAsFixed(2)} Bs').join('\n')}
Total gastado: ${total.toStringAsFixed(2)} Bs

Consejo:
""";
    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${widget.openRouterApiKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://gastoclub.app', // Cambia por tu dominio si tienes uno
        },
        body: jsonEncode({
          'model': 'anthropic/claude-3.5-sonnet', // Puedes cambiar por otro modelo soportado por OpenRouter
          'messages': [
            {'role': 'system', 'content': 'Eres un asesor financiero personal.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 120,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'].toString().trim();
        setState(() {
          _advice = text;
          _loading = false;
        });
      } else {
        setState(() {
          _advice = 'Error: ${response.statusCode} ${response.reasonPhrase}\n${response.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _advice = 'Error al obtener consejo: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colores.paleta[1],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF4EF037)),
                const SizedBox(width: 8),
                const Text(
                  'Consejo IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  tooltip: 'Nuevo consejo',
                  onPressed: _loading ? null : _getAdvice,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_advice != null)
              Text(
                _advice!,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              )
            else
              const Text(
                'Pulsa el botón para obtener un consejo.',
                style: TextStyle(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
