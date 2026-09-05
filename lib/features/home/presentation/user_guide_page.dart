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
          _subscriptionNote(),
          const SizedBox(height: 18),
          _sectionTitle("Flujo recomendado"),
          _stepCard(
            number: "1",
            title: "Crea el catálogo de envases",
            description:
                "Primero define los tipos de envase que usa tu negocio: bins, pallets, cajas, gamelas, bandejas, sacos o bolsas. Este paso solo crea el nombre del envase; todavía no suma cantidad disponible.",
            icon: Icons.warehouse,
            color: Colors.brown,
          ),
          _stepCard(
            number: "2",
            title: "Registra entrada al almacén",
            description:
                "Después de crear el envase, registra cuántos envases físicos entraron a tu bodega. Sin esta entrada, la app no tendrá envases disponibles para cargar stock o crear presentaciones.",
            icon: Icons.input,
            color: Colors.orange,
          ),
          _stepCard(
            number: "3",
            title: "Crea tus clientes",
            description:
                "Registra los clientes que recibirán productos, envases o comprobantes.",
            icon: Icons.people,
            color: Colors.indigo,
          ),
          _stepCard(
            number: "4",
            title: "Crea productos y presentaciones",
            description:
                "Crea tus productos y define sus presentaciones. Una presentación es producto + envase + tipo de cobro + precio. Puede cobrarse por envase completo o por kilo pesado.",
            icon: Icons.inventory_2,
            color: Colors.green,
          ),
          _stepCard(
            number: "5",
            title: "Elige el tipo de cobro",
            description:
                "Usa Por envase cuando el precio corresponde al bin, caja, pallet u otro envase completo. Usa Por kilo cuando el cliente se lleva el envase lleno, se pesa, y el total se calcula por kilos.",
            icon: Icons.sell,
            color: Colors.purple,
          ),
          _stepCard(
            number: "6",
            title: "Agrega detalle opcional",
            description:
                "Si te sirve como referencia, puedes indicar unidad y cantidad por envase. Ejemplo: un bin aproximado de 350 kg. Si un envase contiene otros envases, también puedes indicarlo. Ejemplo: un pallet contiene 80 cajas.",
            icon: Icons.account_tree,
            color: Colors.lightGreen,
          ),
          _stepCard(
            number: "7",
            title: "Carga stock inicial",
            description:
                "Agrega cuántos envases llenos tienes listos para vender. Aunque una presentación cobre por kilo, el stock sigue siendo cantidad de envases llenos.",
            icon: Icons.add_box,
            color: Colors.cyan,
          ),
          _stepCard(
            number: "8",
            title: "Crea una venta",
            description:
                "Selecciona un cliente y agrega una presentación disponible. Si cobra por envase, ingresa cantidad de envases y precio por envase. Si cobra por kilo, ingresa cantidad de envases, kilos pesados y precio por kilo.",
            icon: Icons.point_of_sale,
            color: Colors.blue,
          ),
          _stepCard(
            number: "9",
            title: "Ajusta precio si corresponde",
            description:
                "El precio se carga desde la presentación, pero puedes cambiarlo en una venta puntual si hubo rebaja o acuerdo con el cliente. Ese cambio no modifica el precio base del producto.",
            icon: Icons.price_change,
            color: Colors.greenAccent,
          ),
          _stepCard(
            number: "10",
            title: "Confirma la venta",
            description:
                "Al confirmar, la app descuenta el stock lleno de la presentación vendida y registra automáticamente los envases como entregados al cliente.",
            icon: Icons.check_circle,
            color: Colors.teal,
          ),
          _stepCard(
            number: "11",
            title: "Registra el pago",
            description:
                "Cuando el cliente paga, registra el pago para cerrar la venta y reflejar el ingreso.",
            icon: Icons.payments,
            color: Colors.purple,
          ),
          _stepCard(
            number: "12",
            title: "Genera comprobante si corresponde",
            description:
                "El comprobante es opcional y queda asociado a la venta pagada. No es boleta ni factura tributaria.",
            icon: Icons.receipt_long,
            color: Colors.deepPurple,
          ),
          _stepCard(
            number: "13",
            title: "Revisa inventario",
            description:
                "Consulta envases vacíos disponibles, envases llenos, stock de productos y alertas de inventario.",
            icon: Icons.storage,
            color: Colors.amber,
          ),
          _stepCard(
            number: "14",
            title: "Revisa balance de envases",
            description:
                "Consulta qué clientes tienen envases pendientes y el depósito asociado a esos envases. Una venta por kilo también entrega envases, por lo tanto también afecta el balance.",
            icon: Icons.assessment,
            color: Colors.deepPurpleAccent,
          ),
          _stepCard(
            number: "15",
            title: "Registra devolución de envases",
            description:
                "Si el cliente devuelve envases vacíos después de la venta, regístralo en Bodega > Movimientos > Devolución. Eso descuenta el saldo pendiente del cliente.",
            icon: Icons.assignment_return,
            color: Colors.orangeAccent,
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

  Widget _subscriptionNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.greenAccent.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user,
            color: Colors.greenAccent,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "En el Home puedes ver el estado de tu suscripción. "
              "Por ahora este estado es informativo y no bloquea módulos durante las pruebas internas.",
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
              "Regla importante: crear un envase no agrega stock físico. "
              "Primero crea el catálogo del envase y luego registra una entrada al almacén con la cantidad real disponible.\n\n"
              "Ejemplo: si tienes 100 cajas de ciruelas, primero crea el envase Caja y luego registra una entrada de 100 cajas en bodega.\n\n"
              "El stock de productos siempre se mide en envases llenos. "
              "Si vendes por kilo, la plata se calcula por kilos pesados, pero el inventario descuenta envases llenos.\n\n"
              "Si vendes un pallet, la app descuenta el stock del pallet, no las cajas contenidas. "
              "Para transformar pallets o bins en cajas se usará el flujo futuro de reenvasado.",
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