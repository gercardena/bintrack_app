import 'package:flutter/material.dart';
import '../../data/services/bin_type_service.dart';
import '../../data/models/bin_type_model.dart';

class BinTypesPage extends StatefulWidget {
  const BinTypesPage({super.key});

  @override
  State<BinTypesPage> createState() => _BinTypesPageState();
}

class _BinTypesPageState extends State<BinTypesPage> {

  final BinTypeService service = BinTypeService();

  List<BinType> types = [];

  @override
  void initState() {
    super.initState();
    loadTypes();
  }

  Future<void> loadTypes() async {

    final data = await service.getBinTypes();

    setState(() {
      types = data;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipos de Bins"),
      ),

      body: types.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: types.length,
              itemBuilder: (context, index) {

                final type = types[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(

                    title: Text(
                      type.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Material: ${type.material}"),

                        Text("Depósito: ${type.valorDeposito}"),

                      ],
                    ),
                  ),
                );

              },
            ),
    );

  }
}