import 'package:flutter/material.dart';
import '../data/invoices_service.dart';

class InvoiceHistoryPage extends StatefulWidget {
  const InvoiceHistoryPage({
    super.key,
    required this.invoiceId,
    required this.service,
  });
  final int invoiceId;
  final InvoicesService service;

  @override
  State<InvoiceHistoryPage> createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends State<InvoiceHistoryPage> {
  late Future<List<Map<String, dynamic>>> _history;
  static const _labels = {
    'cliente_nombre': 'Nombre',
    'cliente_direccion': 'Dirección',
    'observaciones': 'Observaciones',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _history = widget.service.historial(widget.invoiceId);
  }

  String _date(Object? value) {
    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return value.toString();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    appBar: AppBar(
      title: const Text('Historial del comprobante'),
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: Colors.white,
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _history,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: () => setState(_load),
              child: const Text('No se pudo cargar. Reintentar'),
            ),
          );
        }
        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return const Center(
            child: Text(
              'Este comprobante aún no tiene modificaciones.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index];
            final changes = entry['cambios'] as Map<String, dynamic>;
            return Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry['usuario_nombre']} · ${_date(entry['fecha'])}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    for (final change in changes.entries) ...[
                      const SizedBox(height: 12),
                      Text(
                        _labels[change.key] ?? change.key,
                        style: const TextStyle(color: Colors.cyanAccent),
                      ),
                      Text(
                        'Antes: ${change.value['antes'] ?? '(sin datos)'}\nDespués: ${change.value['despues'] ?? '(sin datos)'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
