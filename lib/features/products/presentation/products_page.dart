import 'package:flutter/material.dart';

import '../data/products_api.dart';
import '../models/product.dart';
import 'editar_producto_page.dart';
import 'crear_producto_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {

  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    setState(() => loading = true);

    try {
      final data = await ProductsApi.getProducts();

      setState(() {
        products = data;
        loading = false;
      });

    } catch (e) {

      print("ERROR PRODUCTS: $e");

      setState(() => loading = false);
    }
  }

  // 🔥 ELIMINAR CON CONFIRMACIÓN
  Future<void> eliminarProducto(int id) async {

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: const Text("¿Estás seguro?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ProductsApi.eliminarProducto(id);

    if (ok) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto eliminado")),
      );

      cargarProductos();

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar")),
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

      body: RefreshIndicator(
        onRefresh: cargarProductos,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    itemBuilder: (context, index) {

                      final product = products[index];

                      return _productCard(product);
                    },
                  ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CrearProductoPage(),
            ),
          );

          if (result == true) {
            cargarProductos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🔥 CARD GLOBAL PRO
  Widget _productCard(Product product) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            product.name.isNotEmpty ? product.name[0] : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),

        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (product.description != null &&
                product.description!.isNotEmpty)
              Text("📝 ${product.description}"),

            Text("💰 \$${product.price}"),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ✏️ EDITAR
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () async {

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarProductoPage(product: product),
                  ),
                );

                if (result == true) {
                  cargarProductos();
                }
              },
            ),

            // 🗑️ ELIMINAR
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => eliminarProducto(product.id),
            ),
          ],
        ),

        onTap: () async {

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditarProductoPage(product: product),
            ),
          );

          if (result == true) {
            cargarProductos();
          }
        },
      ),
    );
  }

  // 🔥 EMPTY STATE
  Widget _emptyState() {
    return ListView(
      children: const [
        SizedBox(height: 100),
        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text(
            "No hay productos",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}