import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Política de privacidad"),
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _IntroCard(),
          SizedBox(height: 16),
          _SectionCard(
            title: "1. Propósito",
            text:
                "BinTrack es una aplicación de apoyo para la gestión de bodega, clientes, envases, productos, inventario, ventas, pagos y comprobantes internos.",
          ),
          _SectionCard(
            title: "2. Información que registra la app",
            text:
                "BinTrack puede registrar datos del usuario, clientes, envases, movimientos de bodega, productos, presentaciones, precios, stock, inventario, ventas, pagos y comprobantes internos.",
          ),
          _SectionCard(
            title: "3. Uso de la información",
            text:
                "La información se utiliza para operar la aplicación, mantener trazabilidad, mostrar balances, dar soporte durante la marcha blanca, corregir errores y mejorar la experiencia de uso.",
          ),
          _SectionCard(
            title: "4. Acceso a la información",
            text:
                "Durante la marcha blanca, el equipo responsable de BinTrack podrá revisar información operativa solo cuando sea necesario para soporte, corrección de errores o mejora del sistema. BinTrack no vende ni comparte información comercial con terceros para fines publicitarios.",
          ),
          _SectionCard(
            title: "5. Seguridad",
            text:
                "El acceso a la aplicación requiere usuario y contraseña. Cada cuenta mantiene sus datos operativos separados de los demás usuarios.",
          ),
          _SectionCard(
            title: "6. Responsabilidad del usuario",
            text:
                "El usuario debe cuidar sus credenciales de acceso y evitar compartir su contraseña con personas no autorizadas. Si varias personas usan la misma cuenta dentro de una empresa, serán responsables de coordinar internamente su uso.",
          ),
          _SectionCard(
            title: "7. Comprobantes internos",
            text:
                "Los comprobantes generados por BinTrack son documentos internos de apoyo operativo. No reemplazan boletas, facturas ni documentos tributarios oficiales.",
          ),
          _SectionCard(
            title: "8. Corrección o eliminación de datos",
            text:
                "El usuario puede solicitar corrección, revisión o eliminación de datos escribiendo al responsable del sistema.",
          ),
          _SectionCard(
            title: "9. Cambios en esta política",
            text:
                "Esta política puede actualizarse a medida que BinTrack evolucione, especialmente después de la marcha blanca o antes de una publicación comercial formal.",
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF0EA5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            "Política de privacidad de BinTrack",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Última actualización: 07 de septiembre de 2026",
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String text;

  const _SectionCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PrivacyPolicyPage.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}