import 'package:flutter/material.dart';
import '../data/account_service.dart';
import '../models/account_summary.dart';

class SecondaryFormPage extends StatefulWidget {
  const SecondaryFormPage({super.key, required this.service, this.user});
  final AccountService service;
  final SecondaryUser? user;
  @override
  State<SecondaryFormPage> createState() => _SecondaryFormPageState();
}

class _SecondaryFormPageState extends State<SecondaryFormPage> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  bool _saving = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fields = {
      'username': TextEditingController(text: user?.username),
      'email': TextEditingController(text: user?.email),
      'first_name': TextEditingController(text: user?.firstName),
      'last_name': TextEditingController(text: user?.lastName),
      'telefono': TextEditingController(text: user?.phone),
      'password': TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final fields = <String, dynamic>{
      for (final entry in _fields.entries)
        if (widget.user == null ||
            (entry.key != 'username' && entry.key != 'password'))
          entry.key: entry.key == 'password'
              ? entry.value.text
              : entry.value.text.trim(),
    };
    try {
      if (widget.user == null) {
        await widget.service.create(fields);
      } else {
        await widget.service.update(widget.user!.id, fields);
      }
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  Widget _field(String key, String label, int limit, {bool required = false}) {
    final password = key == 'password';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey(key),
        controller: _fields[key],
        enabled: !_saving && !(key == 'username' && widget.user != null),
        obscureText: password && _hidePassword,
        autocorrect: !password && key != 'username' && key != 'email',
        enableSuggestions: !password,
        maxLength: limit,
        keyboardType: key == 'email'
            ? TextInputType.emailAddress
            : key == 'telefono'
            ? TextInputType.phone
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: password
              ? IconButton(
                  tooltip: _hidePassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: _saving
                      ? null
                      : () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                )
              : null,
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Este dato es obligatorio.';
          }
          if (key == 'email' &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())) {
            return 'Ingresa un correo válido.';
          }
          if (password && value!.length < 8) {
            return 'Usa al menos 8 caracteres.';
          }
          if (password && value != value!.trim()) {
            return 'No uses espacios al inicio o al final.';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData.dark(useMaterial3: true),
    child: PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text(
            widget.user == null ? 'Nuevo secundario' : 'Editar secundario',
          ),
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Los secundarios pueden operar el negocio, pero no gestionar usuarios ni suscripción.',
              ),
              const SizedBox(height: 20),
              _field(
                'username',
                'Usuario para iniciar sesión',
                150,
                required: true,
              ),
              _field('email', 'Correo electrónico', 254, required: true),
              _field('first_name', 'Nombre', 150),
              _field('last_name', 'Apellido', 150),
              _field('telefono', 'Teléfono', 20),
              if (widget.user == null) ...[
                _field('password', 'Contraseña', 128, required: true),
                const Text(
                  'Usa una contraseña única y entrégala al usuario por un medio privado. No se mostrará después de guardar.',
                ),
                const SizedBox(height: 16),
              ],
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
                label: Text(_saving ? 'Guardando…' : 'Guardar usuario'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
