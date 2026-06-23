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
    int id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Eliminar producto",
        ),
        content: const Text(
          "¿Estás seguro de eliminar este producto?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await ProductsApi.eliminarProducto(id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Producto eliminado",
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
      appBar: AppBar(
        title: const Text("Productos"),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
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
                      : ListView.builder(
                          padding:
                              const EdgeInsets.all(12),
                          itemCount: products.length,
                          itemBuilder:
                              (context, index) {
                            final product =
                                products[index];

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
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: crearProducto,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _productCard(
    Product product,
    List<ProductPresentation> presentations,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => abrirProducto(product),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      product.nombre.isNotEmpty
                          ? product.nombre[0]
                              .toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: "Editar",
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                    ),
                    onPressed: () =>
                        abrirProducto(product),
                  ),
                  IconButton(
                    tooltip: "Eliminar",
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        eliminarProducto(product.id),
                  ),
                ],
              ),
              if (product.descripcion.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  product.descripcion,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const Text(
                "Presentaciones",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (presentations.isEmpty)
                const Text(
                  "Sin presentaciones registradas",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
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

  Widget _presentationRow(
    ProductPresentation presentation,
  ) {
    final color = presentation.activo
        ? Colors.green
        : Colors.grey;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Precio: "
                  "\$${presentation.precio.toStringAsFixed(0)}",
                ),
                Text(
                  "Stock lleno: "
                  "${presentation.stockCantidad}",
                ),
              ],
            ),
          ),
          Text(
            presentation.activo
                ? "Activa"
                : "Inactiva",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: const [
        SizedBox(height: 100),
        Icon(
          Icons.inventory_2_outlined,
          size: 80,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            "No hay productos",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: cargarProductos,
      child: ListView(
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Error cargando productos",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Text(
              errorMessage ?? "",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}