import 'package:flutter/material.dart';
import '../data/invoices_service.dart';
import '../models/invoice_model.dart';

class EditInvoicePage extends StatefulWidget {
  const EditInvoicePage({
    super.key,
    required this.invoice,
    required this.service,
  });
  final Invoice invoice;
  final InvoicesService service;

  @override
  State<EditInvoicePage> createState() => _EditInvoicePageState();
}

class _EditInvoicePageState extends State<EditInvoicePage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _direccion;
  late final TextEditingController _observaciones;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.invoice.clienteNombre);
    _direccion = TextEditingController(
      text: widget.invoice.clienteDireccion ?? '',
    );
    _observaciones = TextEditingController(text: widget.invoice.observaciones);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await widget.service.editar(
        widget.invoice,
        nombre: _nombre.text.trim(),
        direccion: _direccion.text.trim(),
        observaciones: _observaciones.text.trim(),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.of(context).pop(updated);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  Widget _field(
    TextEditingController controller,
    String label,
    int limit, {
    bool required = false,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !_saving,
        maxLength: limit,
        maxLines: lines,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.cyanAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          counterStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color(0xFF1E293B),
        ),
        validator: (value) =>
            required && (value == null || value.trim().isEmpty)
            ? 'El nombre es obligatorio.'
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: const Text('Editar comprobante'),
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Comprobante ${widget.invoice.numero}\nRUT: ${widget.invoice.clienteRut}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Text(
                'Corrige datos del mismo cliente. La venta, el RUT, los productos y los importes no cambian. Cada modificación quedará registrada.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _field(_nombre, 'Nombre del cliente', 255, required: true),
              _field(_direccion, 'Dirección del cliente', 255, lines: 2),
              _field(_observaciones, 'Observaciones', 2000, lines: 4),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Guardando…' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
