import 'package:flutter/material.dart';

import '../../data/models/bin_type_model.dart';
import '../../data/services/bin_type_service.dart';

import 'create_bin_type_page.dart';

class BinTypesPage extends StatefulWidget {
  const BinTypesPage({super.key});

  @override
  State<BinTypesPage> createState() => _BinTypesPageState();
}

class _BinTypesPageState extends State<BinTypesPage> {
  final BinTypeService service = BinTypeService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<BinType> types = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTypes();
  }

  Future<void> loadTypes() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await service.getBinTypes();

      if (!mounted) return;

      setState(() {
        types = data;
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

  Future<void> openCreatePage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateBinTypePage(),
      ),
    );

    if (result == true && mounted) {
      await loadTypes();
    }
  }

  Future<void> openEditPage(BinType type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateBinTypePage(
          binType: type,
        ),
      ),
    );

    if (result == true && mounted) {
      await loadTypes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Tipos de envase"),
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openCreatePage,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _errorState()
              : RefreshIndicator(
                  onRefresh: loadTypes,
                  child: types.isEmpty
                      ? _emptyState()
                      : ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            _introCard(),
                            const SizedBox(height: 14),
                            ...types.map(_typeCard),
                          ],
                        ),
                ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blueAccent.withValues(alpha: 0.30),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.inventory_2,
            color: Colors.blueAccent,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Aquí defines el catálogo de envases que usa tu operación. "
              "Crear un envase no agrega stock físico; para sumar cantidad "
              "disponible debes registrar una entrada en Bodega > Movimientos.",
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

  Widget _typeCard(BinType type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent.withValues(
              alpha: 0.18,
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _infoLine(
                  Icons.category,
                  "Tipo: ${type.tipoNombre}",
                ),
                if (type.material.trim().isNotEmpty)
                  _infoLine(
                    Icons.construction,
                    "Material: ${type.material}",
                  ),
                _infoLine(
                  Icons.savings_outlined,
                  "Depósito por envase: \$${type.valorDeposito}",
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => openEditPage(type),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(
                        color: Colors.blueAccent,
                      ),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                    ),
                    label: const Text("Editar"),
                  ),
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
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 17,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
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

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.inventory_2_outlined,
          color: Colors.white38,
          size: 64,
        ),
        SizedBox(height: 16),
        Text(
          "No hay tipos de envase creados",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Crea primero el catálogo del envase. Luego registra una entrada "
          "para indicar cuántos envases físicos hay disponibles.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              "No se pudieron cargar los tipos de envase",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: loadTypes,
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}