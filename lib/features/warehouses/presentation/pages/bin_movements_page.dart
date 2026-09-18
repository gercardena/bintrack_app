import 'package:flutter/material.dart';

import '../../data/services/bin_movement_service.dart';
import '../../data/models/bin_movement_model.dart';

import 'create_bin_movement_page.dart';

class BinMovementsPage extends StatefulWidget {
  const BinMovementsPage({super.key});

  @override
  State<BinMovementsPage> createState() =>
      _BinMovementsPageState();
}

class _BinMovementsPageState
    extends State<BinMovementsPage> {
  final BinMovementService service = BinMovementService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  final TextEditingController buscarController =
      TextEditingController();

  List<BinMovement> movements = [];
  bool loading = true;
  String? errorMessage;

  List<BinMovement> get movimientosFiltrados {
    final query = buscarController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      return movements;
    }

    return movements.where((movement) {
      final texto = [
        movementLabel(movement.tipoMovimiento),
        movement.tipoMovimiento,
        movement.clienteNombre,
        movement.binNombre,
        movement.cantidad.toString(),
        movement.depositoPagado.toString(),
        movement.referencia,
        movement.fecha,
      ].join(" ").toLowerCase();

      return texto.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadMovements();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> loadMovements() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await service.getMovements();

      if (!mounted) return;

      setState(() {
        movements = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> crearMovimiento() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateBinMovementPage(),
      ),
    );

    if (result == true && mounted) {
      await loadMovements();
    }
  }

  String movementLabel(String value) {
    switch (value) {
      case "entrada":
        return "Entrada";
      case "prestamo":
        return "Préstamo";
      case "devolucion":
        return "Devolución";
      case "baja":
        return "Baja";
      default:
        return value;
    }
  }

  Color movementColor(String value) {
    switch (value) {
      case "entrada":
        return Colors.greenAccent;
      case "prestamo":
        return Colors.orangeAccent;
      case "devolucion":
        return Colors.cyanAccent;
      case "baja":
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  IconData movementIcon(String value) {
    switch (value) {
      case "entrada":
        return Icons.call_received;
      case "prestamo":
        return Icons.call_made;
      case "devolucion":
        return Icons.assignment_return;
      case "baja":
        return Icons.delete_outline;
      default:
        return Icons.swap_horiz;
    }
  }

  String movementHelp(String value) {
    switch (value) {
      case "entrada":
        return "Aumenta los envases físicos disponibles.";
      case "prestamo":
        return "Entrega envases a un cliente.";
      case "devolucion":
        return "Registra envases que vuelven desde cliente.";
      case "baja":
        return "Marca envases perdidos, rotos o no utilizables.";
      default:
        return "Movimiento de envases.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibles = movimientosFiltrados;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Movimientos"),
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _errorState()
              : RefreshIndicator(
                  onRefresh: loadMovements,
                  child: movements.isEmpty
                      ? _emptyState()
                      : ListView(
                          padding:
                              const EdgeInsets.all(16),
                          children: [
                            _introCard(),
                            const SizedBox(height: 14),
                            _searchCard(),
                            const SizedBox(height: 14),
                            if (visibles.isEmpty)
                              _emptySearchState()
                            else
                              ...visibles.map(
                                _movementCard,
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: crearMovimiento,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo movimiento"),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orangeAccent.withValues(alpha: 0.30),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.swap_horiz,
            color: Colors.orangeAccent,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Aquí se registran entradas, préstamos, devoluciones "
              "y bajas de envases. Estos movimientos alimentan el "
              "inventario y el balance por cliente.",
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchCard() {
    final buscando = buscarController.text
        .trim()
        .isNotEmpty;

    final totalResultados = movimientosFiltrados.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          TextField(
            controller: buscarController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: Colors.orangeAccent,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  Colors.white.withValues(alpha: 0.08),
              labelText: "Buscar movimiento",
              hintText:
                  "Cliente, envase, tipo, referencia...",
              labelStyle: const TextStyle(
                color: Colors.white70,
              ),
              hintStyle: const TextStyle(
                color: Colors.white38,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white54,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      Colors.white.withValues(alpha: 0.14),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.orangeAccent,
                ),
              ),
              suffixIcon: buscando
                  ? IconButton(
                      tooltip: "Limpiar búsqueda",
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          buscarController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          Text(
            buscando
                ? "Mostrando $totalResultados de ${movements.length} movimiento(s)."
                : "Busca por cliente, envase, tipo, referencia, fecha o cantidad.",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _movementCard(
    BinMovement movement,
  ) {
    final color = movementColor(
      movement.tipoMovimiento,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                color.withValues(alpha: 0.16),
            child: Icon(
              movementIcon(movement.tipoMovimiento),
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  movementLabel(
                    movement.tipoMovimiento,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movementHelp(
                    movement.tipoMovimiento,
                  ),
                  style: const TextStyle(
                    color: Colors.white60,
                    height: 1.25,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 10),
                _infoLine(
                  Icons.numbers,
                  "Cantidad: ${movement.cantidad}",
                ),
                _infoLine(
                  Icons.person_outline,
                  "Cliente: ${movement.clienteNombre}",
                ),
                _infoLine(
                  Icons.inventory_2_outlined,
                  "Envase: ${movement.binNombre}",
                ),
                _infoLine(
                  Icons.savings_outlined,
                  "Depósito pagado: \$${movement.depositoPagado}",
                ),
                if (movement.referencia.isNotEmpty)
                  _infoLine(
                    Icons.notes_outlined,
                    "Referencia: ${movement.referencia}",
                  ),
                _infoLine(
                  Icons.calendar_today,
                  "Fecha: ${movement.fecha}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white54,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySearchState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orangeAccent.withValues(alpha: 0.24),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            color: Colors.orangeAccent,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            "No encontramos movimientos",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Prueba buscando por cliente, envase, tipo, referencia o fecha.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.swap_horiz,
          size: 82,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "No hay movimientos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Registra una entrada para cargar envases físicos, "
          "o un préstamo/devolución para controlar envases por cliente.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: crearMovimiento,
          icon: const Icon(Icons.add),
          label: const Text("Crear movimiento"),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: loadMovements,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          const Icon(
            Icons.error_outline,
            size: 72,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "No pudimos cargar los movimientos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: loadMovements,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}