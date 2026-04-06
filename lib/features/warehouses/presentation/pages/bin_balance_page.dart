import 'package:flutter/material.dart';
import '../../data/services/bin_balance_service.dart';
import '../../data/models/bin_balance_model.dart';

class BinBalancePage extends StatefulWidget {
  const BinBalancePage({super.key});

  @override
  State<BinBalancePage> createState() => _BinBalancePageState();
}

class _BinBalancePageState extends State<BinBalancePage> {

  final BinBalanceService service = BinBalanceService();

  List<BinBalance> balances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBalance();
  }

  Future<void> loadBalance() async {
    try {
      final data = await service.getBalance();

      setState(() {
        balances = data;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print("ERROR BALANCE: $e");
    }
  }

  // 🔥 WIDGET TOTALES
  Widget buildTotals() {

    int totalSaldo = balances.fold(0, (sum, b) => sum + b.saldo);

    double totalDeposito = balances.fold(
      0,
      (sum, b) => sum + double.parse(b.depositoPendiente),
    );

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Totales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Saldo total: $totalSaldo"),
            Text("Depósito total: \$${totalDeposito.toStringAsFixed(0)}"),
          ],
        ),
      ),
    );
  }

  // 🔥 WIDGET LISTA
  Widget buildList() {
    return ListView.builder(
      itemCount: balances.length,
      itemBuilder: (context, index) {

        final b = balances[index];

        final colorSaldo = b.saldo > 0 ? Colors.red : Colors.green;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 👤 CLIENTE
                Text(
                  b.clienteNombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // 📊 DATOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Entregados: ${b.entregados}"),
                    Text("Devueltos: ${b.devueltos}"),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  "Saldo: ${b.saldo}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorSaldo,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Depósito: \$${b.depositoPendiente}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 WIDGET ESTADO VACÍO
  Widget buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Sin movimientos aún",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Registra entregas o devoluciones\npara ver el balance",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Balance de Envases"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : balances.isEmpty
              ? buildEmpty()
              : Column(
                  children: [
                    buildTotals(),
                    Expanded(child: buildList()),
                  ],
                ),
    );
  }
}