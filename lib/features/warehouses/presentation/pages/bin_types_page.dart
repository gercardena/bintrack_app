import 'package:flutter/material.dart';
import '../../data/services/bin_type_service.dart';
import '../../data/models/bin_type_model.dart';
import 'create_bin_type_page.dart';

class BinTypesPage extends StatefulWidget {
  const BinTypesPage({super.key});

  @override
  State<BinTypesPage> createState() => _BinTypesPageState();
}

class _BinTypesPageState extends State<BinTypesPage> {

  final BinTypeService service = BinTypeService();

  List<BinType> types = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTypes();
  }

  Future<void> loadTypes() async {

    setState(() {
      loading = true;
    });

    try {

      final data = await service.getBinTypes();

      setState(() {
        types = data;
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  Future<void> openCreatePage() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CreateBinTypePage(),
      ),
    );

    if (result == true) {
      await loadTypes();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Tipos de Envase"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openCreatePage,
        child: const Icon(Icons.add),
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : types.isEmpty

              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 70,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "No existen tipos de envase",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Agrega el primer tipo de envase",
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: openCreatePage,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "Nuevo Tipo de Envase",
                        ),
                      ),
                    ],
                  ),
                )

              : ListView.builder(
                  itemCount: types.length,
                  itemBuilder: (context, index) {

                    final type = types[index];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: ListTile(

                        title: Text(
                          type.nombre,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              "Material: ${type.material}",
                            ),

                            Text(
                              "Depósito: ${type.valorDeposito}",
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