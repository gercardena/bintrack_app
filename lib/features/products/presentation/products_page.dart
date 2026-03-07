import 'package:flutter/material.dart';

import '../data/products_api.dart';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {

  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = ProductsApi.getProducts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
      ),

      body: FutureBuilder<List<Product>>(
        future: _futureProducts,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error cargando productos"),
            );
          }

          final products = snapshot.data!;

          if (products.isEmpty) {
            return const Center(
              child: Text("No hay productos"),
            );
          }

          return ListView.builder(
            itemCount: products.length,

            itemBuilder: (context, index) {

              final product = products[index];

              return ListTile(
                title: Text(product.name),
                subtitle: Text("SKU: ${product.sku}"),
                trailing: Text("\$${product.price}"),
              );
            },
          );
        },
      ),
    );
  }
}