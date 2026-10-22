import 'package:flutter/material.dart';

import '../../clientes/models/cliente.dart';

/// Returns a client only after an explicit selection; closing cancels the search.
class SaleClientPicker extends StatefulWidget {
  const SaleClientPicker({super.key, required this.clientes, this.selectedId});

  final List<Cliente> clientes;
  final int? selectedId;

  @override
  State<SaleClientPicker> createState() => _SaleClientPickerState();
}

class _SaleClientPickerState extends State<SaleClientPicker> {
  final _search = TextEditingController();

  String _normalize(String value) {
    var result = value.toLowerCase().trim();
    const accents = 'áéíóúü';
    const plain = 'aeiouu';
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], plain[i]);
    }
    return result.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _rut(String value) => value.replaceAll(RegExp(r'[.\s-]'), '');

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _normalize(_search.text);
    final rutQuery = _rut(query);
    final matches = widget.clientes.where((cliente) {
      return cliente.activo &&
          (query.isEmpty ||
              _normalize(cliente.nombre).contains(query) ||
              (rutQuery.isNotEmpty &&
                  _rut(cliente.rut.toLowerCase()).contains(rutQuery)));
    }).toList();

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text(
        'Seleccionar cliente',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 440,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _search,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.cyanAccent,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nombre o RUT',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () => setState(_search.clear),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: matches.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay clientes activos que coincidan con la búsqueda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final cliente = matches[index];
                        return ListTile(
                          title: Text(
                            cliente.nombre,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'RUT: ${cliente.rut}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: cliente.id == widget.selectedId
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.cyanAccent,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(cliente),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.cyanAccent),
          ),
        ),
      ],
    );
  }
}
