import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/auth/user_controller.dart';
import '../../../core/services/api_service.dart';
import '../../home/presentation/home_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, this.requiredChange = false});
  final bool requiredChange;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _busy = false;
  bool _hideCurrent = true;
  bool _hideNew = true;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response = await ApiService.put(
        '/accounts/user/change-password/',
        body: {
          'contrasena_actual': _currentController.text,
          'nueva_contrasena': _newController.text,
        },
      );
      if (response.statusCode != 200) {
        throw Exception(_messageFrom(response.body));
      }
      await UserController().loadUser();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageFrom(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data.values.map((value) {
          if (value is List) return value.join(' ');
          return value.toString();
        }).join(' ');
      }
    } catch (_) {
      // Conservamos un mensaje seguro y comprensible.
    }
    return 'No fue posible actualizar la contraseña. Intenta nuevamente.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF101827),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF172033),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.lock_reset_outlined, size: 48, color: Colors.cyanAccent),
                        const SizedBox(height: 16),
                        Text(
                          widget.requiredChange
                              ? 'Crea tu contraseña personal'
                              : 'Cambiar contraseña',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.requiredChange
                              ? 'Tu cuenta fue creada con una contraseña temporal. Para continuar, define una clave que solo tú conozcas.'
                              : 'Actualiza tu contraseña. Necesitarás conocer tu clave actual.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, height: 1.35),
                        ),
                        const SizedBox(height: 22),
                        _field(
                          controller: _currentController,
                          label: widget.requiredChange
                              ? 'Contraseña temporal'
                              : 'Contraseña actual',
                          obscure: _hideCurrent,
                          onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _newController,
                          label: 'Nueva contraseña',
                          obscure: _hideNew,
                          onToggle: () => setState(() => _hideNew = !_hideNew),
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Usa al menos 8 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _confirmController,
                          label: 'Repite la nueva contraseña',
                          obscure: _hideNew,
                          onToggle: () => setState(() => _hideNew = !_hideNew),
                          validator: (value) => value != _newController.text
                              ? 'Las contraseñas no coinciden.'
                              : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _busy ? null : _save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                          child: _busy
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Guardar y continuar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) => TextFormField(
        controller: controller,
        obscureText: obscure,
        autocorrect: false,
        enableSuggestions: false,
        style: const TextStyle(color: Colors.white),
        validator: validator ?? (value) => value == null || value.isEmpty ? 'Este campo es obligatorio.' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          suffixIcon: IconButton(
            tooltip: obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
            onPressed: onToggle,
            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}
