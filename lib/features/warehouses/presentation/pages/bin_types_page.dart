import 'package:flutter/material.dart';

import '../../data/services/bin_type_service.dart';
import '../../data/models/bin_type_model.dart';

import 'create_bin_type_page.dart';

class BinTypesPage extends StatefulWidget {
  const BinTypesPage({super.key});

  @override
  State<BinTypesPage> createState() =>
      _BinTypesPageState();
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
                          padding:
                              const EdgeInsets.all(16),
                          children: [
                            _introCard(),
                            const SizedBox(height: 14),
                            ...types.map(
                              _typeCard,
                            ),
                          ],
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: openCreatePage,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo envase"),
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
              "Define los tipos de envase que usará tu operación: "
              "bins, pallets, cajas u otros. Cada uno puede tener "
              "un valor de depósito como garantía.",
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

  Widget _typeCard(
    BinType type,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
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
                Colors.blueAccent.withValues(alpha: 0.18),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  type.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                if (type.material.isNotEmpty)
                  _infoLine(
                    Icons.construction,
                    "Material: ${type.material}",
                  ),

                _infoLine(
                  Icons.savings_outlined,
                  "Depósito por envase: \$${type.valorDeposito}",
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

  Widget _emptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.inventory_2_outlined,
          size: 82,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "No hay tipos de envase",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Crea tu primer tipo de envase para poder registrar "
          "entradas, préstamos, devoluciones y stock.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: openCreatePage,
          icon: const Icon(Icons.add),
          label: const Text("Crear tipo de envase"),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: loadTypes,
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
              "No pudimos cargar los tipos de envase",
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
            onPressed: loadTypes,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}