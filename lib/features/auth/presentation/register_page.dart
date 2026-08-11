import 'package:flutter/material.dart';

import '../data/auth_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rutController = TextEditingController();
  final telefonoController = TextEditingController();

  bool saving = false;
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rutController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
      errorMessage = null;
    });

    try {
      await AuthApi.register(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        rut: rutController.text.trim(),
        telefono: telefonoController.text.trim(),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Cuenta creada"),
            content: const Text(
              "Tu cuenta fue creada correctamente.\n\n"
              "La suscripción queda pendiente de activación para la marcha blanca.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("Entendido"),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst(
              "Exception: ",
              "",
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  String? requiredValidator(
    String? value,
    String message,
  ) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Ingresa tu email";
    }

    if (!value.contains("@")) {
      return "Ingresa un email válido";
    }

    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Ingresa una contraseña";
    }

    if (value.trim().length < 6) {
      return "La contraseña debe tener al menos 6 caracteres";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        centerTitle: true,
        backgroundColor: const Color(0xFF101827),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 22),
                  _formCard(),
                  const SizedBox(height: 18),
                  const Text(
                    "Después del registro podrás iniciar sesión cuando tu suscripción esté activa.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Icon(
          Icons.person_add_alt_1,
          color: Colors.cyanAccent,
          size: 48,
        ),
        SizedBox(height: 12),
        Text(
          "Crear cuenta BinTrack",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Registra tus datos para solicitar acceso a la marcha blanca.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            _input(
              controller: usernameController,
              label: "Usuario",
              icon: Icons.person_outline,
              validator: (value) => requiredValidator(
                value,
                "Ingresa un usuario",
              ),
            ),
            const SizedBox(height: 14),
            _input(
              controller: emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
            ),
            const SizedBox(height: 14),
            _input(
              controller: passwordController,
              label: "Contraseña",
              icon: Icons.lock_outline,
              obscureText: obscurePassword,
              validator: passwordValidator,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white54,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _input(
              controller: rutController,
              label: "RUT (opcional)",
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 14),
            _input(
              controller: telefonoController,
              label: "Teléfono (opcional)",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              _errorBox(errorMessage!),
            ],
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: saving ? null : register,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white60,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white54,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0F172A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.cyanAccent,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}