import 'package:flutter/material.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Guía de usuario"),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _introCard(),
          const SizedBox(height: 18),
          _sectionTitle("Flujo recomendado"),
          _stepCard(
            number: "1",
            title: "Configura tus envases",
            description:
                "Crea los envases que usa tu negocio, como bins, pallets, cajas, gamelas, bandejas, sacos o bolsas.",
            icon: Icons.warehouse,
            color: Colors.brown,
          ),
          _stepCard(
            number: "2",
            title: "Registra entrada de envases",
            description:
                "Antes de cargar stock de productos, registra cuántos envases disponibles tienes en bodega.",
            icon: Icons.input,
            color: Colors.orange,
          ),
          _stepCard(
            number: "3",
            title: "Crea productos y presentaciones",
            description:
                "Crea tus productos y define cómo se venden: por caja, pallet, bin u otro envase. Cada presentación tiene precio y stock propio.",
            icon: Icons.inventory_2,
            color: Colors.green,
          ),
          _stepCard(
            number: "4",
            title: "Agrega detalle de presentación",
            description:
                "Si una presentación contiene otra, indícalo en el detalle. Por ejemplo: un pallet contiene 80 cajas.",
            icon: Icons.account_tree,
            color: Colors.lightGreen,
          ),
          _stepCard(
            number: "5",
            title: "Crea tus clientes",
            description:
                "Registra los clientes que recibirán productos o envases.",
            icon: Icons.people,
            color: Colors.indigo,
          ),
          _stepCard(
            number: "6",
            title: "Crea una venta",
            description:
                "Selecciona un cliente y agrega una presentación disponible, como Ciruelas + Caja de Ciruelas o Ciruelas + Pallet Madera.",
            icon: Icons.point_of_sale,
            color: Colors.blue,
          ),
          _stepCard(
            number: "7",
            title: "Confirma la venta",
            description:
                "Al confirmar, la app descuenta el stock de la presentación vendida.",
            icon: Icons.check_circle,
            color: Colors.teal,
          ),
          _stepCard(
            number: "8",
            title: "Registra el pago",
            description:
                "Cuando el cliente paga, registra el pago para cerrar la venta.",
            icon: Icons.payments,
            color: Colors.purple,
          ),
          _stepCard(
            number: "9",
            title: "Genera comprobante si corresponde",
            description:
                "El comprobante es opcional y queda asociado a la venta pagada. No es boleta ni factura tributaria.",
            icon: Icons.receipt_long,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 18),
          _warningCard(),
        ],
      ),
    );
  }

  Widget _introCard() {
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
            Icons.route,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            "Cómo usar BINTRACK",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Sigue este orden para evitar errores de inventario y mantener trazabilidad clara.",
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _stepCard({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Regla importante: para cargar stock de una presentación, primero debe existir entrada de envases disponibles. Ejemplo: antes de crear 100 cajas de ciruelas con stock, registra una entrada de 100 cajas en bodega.",
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}