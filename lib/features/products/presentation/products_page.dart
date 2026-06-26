import 'package:flutter/material.dart';

import '../data/products_api.dart';
import '../data/product_presentations_service.dart';

import '../data/models/product_model.dart';
import '../data/models/product_presentation_model.dart';

import 'editar_producto_page.dart';
import 'crear_producto_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() =>
      _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductPresentationsService presentationsService =
      ProductPresentationsService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<Product> products = [];

  Map<int, List<ProductPresentation>>
      presentationsByProduct = {};

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final productData =
          await ProductsApi.getProducts();

      final presentationData =
          await presentationsService.getAll();

      final grouped =
          <int, List<ProductPresentation>>{};

      for (final presentation in presentationData) {
        grouped
            .putIfAbsent(
              presentation.productId,
              () => [],
            )
            .add(presentation);
      }

      if (!mounted) return;

      setState(() {
        products = productData;
        presentationsByProduct = grouped;
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

  Future<void> abrirProducto(
    Product product,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarProductoPage(
          product: product,
        ),
      ),
    );

    if (mounted) {
      await cargarProductos();
    }
  }

  Future<void> crearProducto() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CrearProductoPage(),
      ),
    );

    if (result == true && mounted) {
      await cargarProductos();
    }
  }

  Future<void> eliminarProducto(
    Product product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Eliminar producto",
        ),
        content: Text(
          "¿Seguro que quieres eliminar "
          "${product.nombre}?\n\n"
          "Esta acción también puede afectar sus "
          "presentaciones asociadas.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await ProductsApi.eliminarProducto(
      product.id,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${product.nombre} eliminado",
          ),
        ),
      );

      await cargarProductos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No fue posible eliminar el producto",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Productos"),
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
                  onRefresh: cargarProductos,
                  child: products.isEmpty
                      ? _emptyState()
                      : ListView(
                          padding:
                              const EdgeInsets.all(16),
                          children: [
                            _headerCard(),
                            const SizedBox(height: 14),
                            ...products.map(
                              (product) {
                                final presentations =
                                    presentationsByProduct[
                                            product.id] ??
                                        [];

                                return _productCard(
                                  product,
                                  presentations,
                                );
                              },
                            ),
                          ],
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: crearProducto,
        icon: const Icon(Icons.add),
        label: const Text("Nuevo producto"),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(
          alpha: 0.14,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.inventory_2,
            color: Colors.greenAccent,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Aquí se administran los productos y sus "
              "presentaciones. Una presentación es la "
              "combinación de producto + envase + precio.",
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

  Widget _productCard(
    Product product,
    List<ProductPresentation> presentations,
  ) {
    final activePresentations = presentations
        .where(
          (presentation) => presentation.activo,
        )
        .length;

    final totalStock = presentations.fold<int>(
      0,
      (total, presentation) =>
          total + presentation.stockCantidad,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => abrirProducto(product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        const Color(0xFF22C55E),
                    child: Text(
                      product.nombre.isNotEmpty
                          ? product.nombre[0]
                              .toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "$activePresentations presentación(es) activa(s)",
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Editar",
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.amber,
                    ),
                    onPressed: () =>
                        abrirProducto(product),
                  ),
                  IconButton(
                    tooltip: "Eliminar",
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () =>
                        eliminarProducto(product),
                  ),
                ],
              ),

              if (product.descripcion.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  product.descripcion,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],

              const SizedBox(height: 14),

              Row(
                children: [
                  _miniInfo(
                    icon: Icons.category,
                    label: "Presentaciones",
                    value: "${presentations.length}",
                    color: Colors.cyan,
                  ),
                  const SizedBox(width: 10),
                  _miniInfo(
                    icon: Icons.inventory,
                    label: "Stock lleno",
                    value: "$totalStock",
                    color: Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Text(
                "Presentaciones y stock",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              if (presentations.isEmpty)
                _noPresentations()
              else
                ...presentations.map(
                  _presentationRow,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noPresentations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.28),
        ),
      ),
      child: const Text(
        "Este producto aún no tiene presentaciones. "
        "Entra a editarlo para agregar un envase y precio.",
        style: TextStyle(
          color: Colors.white70,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _presentationRow(
    ProductPresentation presentation,
  ) {
    final color = presentation.activo
        ? Colors.greenAccent
        : Colors.grey;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            presentation.activo
                ? Icons.inventory_2
                : Icons.block,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  presentation.binNombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Precio por envase: "
                  "\$${presentation.precio.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  "Envases llenos disponibles: "
                  "${presentation.stockCantidad}",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            presentation.activo
                ? "Activa"
                : "Inactiva",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
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
        const SizedBox(height: 80),
        Icon(
          Icons.inventory_2_outlined,
          size: 80,
          color: Colors.white.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "Todavía no hay productos",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Crea tu primer producto indicando su envase, "
          "precio y stock inicial de envases llenos.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: crearProducto,
          icon: const Icon(Icons.add),
          label: const Text("Crear producto"),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: cargarProductos,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          const Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "No pudimos cargar los productos",
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
            onPressed: cargarProductos,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}