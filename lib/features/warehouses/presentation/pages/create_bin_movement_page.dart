import 'package:flutter/material.dart';

import '../../data/models/bin_client_model.dart';
import '../../data/models/bin_type_model.dart';
import '../../data/services/bin_client_service.dart';
import '../../data/services/bin_type_service.dart';
import '../../data/services/bin_movement_service.dart';

class CreateBinMovementPage extends StatefulWidget {
  const CreateBinMovementPage({super.key});

  @override
  State<CreateBinMovementPage> createState() =>
      _CreateBinMovementPageState();
}

class _CreateBinMovementPageState
    extends State<CreateBinMovementPage> {
  final BinClientService clientService =
      BinClientService();

  final BinTypeService typeService = BinTypeService();

  final BinMovementService movementService =
      BinMovementService();

  static const Color background = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);

  List<BinClient> clients = [];
  List<BinType> types = [];

  BinClient? selectedClient;
  BinType? selectedType;

  // La acción más frecuente es prestar un bin a un cliente.
  String movementType = "prestamo";

  final cantidadController = TextEditingController();
  final depositoRecibidoController = TextEditingController();
  final depositoDevueltoController = TextEditingController();
  final referenciaController = TextEditingController();

  bool loading = true;
  bool saving = false;

  bool get requiereCliente {
    return movementType == "prestamo" ||
        movementType == "devolucion";
  }

  bool get muestraDepositoRecibido {
    return movementType == "prestamo";
  }

  bool get muestraDepositoDevuelto {
    return movementType == "devolucion";
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    cantidadController.dispose();
    depositoRecibidoController.dispose();
    depositoDevueltoController.dispose();
    referenciaController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final loadedClients =
          await clientService.getClients();

      final loadedTypes = await typeService.getBinTypes();

      if (!mounted) return;

      setState(() {
        clients = loadedClients;
        types = loadedTypes;

        if (types.isNotEmpty) {
          selectedType = types.first;
        }

        selectedClient = null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error cargando datos: $e",
          ),
        ),
      );
    }
  }

  String movementLabel(String value) {
    switch (value) {
      case "entrada":
        return "Entrada al almacén";
      case "prestamo":
        return "Préstamo a cliente";
      case "devolucion":
        return "Devolución de cliente";
      case "baja":
        return "Baja de envases";
      default:
        return value;
    }
  }

  String movementDescription(String value) {
    switch (value) {
      case "entrada":
        return "Usa Entrada cuando recibes envases vacíos en el almacén. Aumenta los envases disponibles y no requiere cliente.";
      case "prestamo":
        return "Usa Préstamo cuando entregas envases vacíos a un cliente. El cliente queda con saldo pendiente.";
      case "devolucion":
        return "Usa Devolución cuando un cliente devuelve envases vacíos al almacén, incluso si esos envases salieron antes en una venta. Reduce su saldo pendiente y aumenta los envases vacíos disponibles.";
      case "baja":
        return "Usa Baja para descontar envases rotos, perdidos o no utilizables. No requiere cliente.";
      default:
        return "Movimiento de envases.";
    }
  }

  String clienteHelp() {
    if (movementType == "prestamo") {
      return "Selecciona el cliente que recibe los envases.";
    }

    if (movementType == "devolucion") {
      return "Selecciona el cliente que devuelve los envases.";
    }

    return "Este movimiento no requiere cliente.";
  }

  String referenciaSugerida() {
    switch (movementType) {
      case "entrada":
        return "Entrada al almacén";
      case "prestamo":
        return "Préstamo a cliente";
      case "devolucion":
        return "Devolución de cliente";
      case "baja":
        return "Baja de envases";
      default:
        return "Movimiento";
    }
  }

  Color movementColor(String value) {
    switch (value) {
      case "entrada":
        return Colors.greenAccent;
      case "prestamo":
        return Colors.orangeAccent;
      case "devolucion":
        return Colors.cyanAccent;
      case "baja":
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  bool validarFormulario() {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecciona un tipo de envase.",
          ),
        ),
      );
      return false;
    }

    if (requiereCliente && selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            movementType == "prestamo"
                ? "Selecciona el cliente que recibe los envases."
                : "Selecciona el cliente que devuelve los envases.",
          ),
        ),
      );
      return false;
    }

    final cantidad =
        int.tryParse(cantidadController.text.trim()) ?? 0;

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La cantidad debe ser mayor que cero.",
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> saveMovement() async {
    if (saving) return;

    if (!validarFormulario()) return;

    final depositoRecibido = muestraDepositoRecibido
        ? double.tryParse(
              depositoRecibidoController.text
                  .trim()
                  .replaceAll(",", "."),
            ) ??
            0
        : 0.0;
    final depositoDevuelto = muestraDepositoDevuelto
        ? double.tryParse(
              depositoDevueltoController.text
                  .trim()
                  .replaceAll(",", "."),
            ) ??
            0
        : 0.0;

    setState(() {
      saving = true;
    });

    try {
      final ok = await movementService.createMovement(
        cliente:
            requiereCliente ? selectedClient!.id : null,
        binType: selectedType!.id,
        tipoMovimiento: movementType,
        cantidad: int.parse(
          cantidadController.text.trim(),
        ),
        depositoPagado: depositoRecibido,
        depositoDevuelto: depositoDevuelto,
        referencia:
            referenciaController.text.trim().isEmpty
                ? referenciaSugerida()
                : referenciaController.text.trim(),
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${movementLabel(movementType)} registrado correctamente.",
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        setState(() {
          saving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No fue posible crear el movimiento.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No fue posible crear el movimiento: $e",
          ),
        ),
      );
    }
  }

  Future<void> seleccionarCliente() async {
    final searchController = TextEditingController();
    final selected = await showModalBottomSheet<BinClient>(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchController.text.trim().toLowerCase();
            final matches = clients.where((client) {
              return client.nombre.toLowerCase().contains(query);
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.72,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buscar cliente',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (_) => setModalState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Nombre del cliente',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: matches.isEmpty
                            ? const Center(
                                child: Text(
                                  'No encontramos clientes.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.separated(
                                itemCount: matches.length,
                                separatorBuilder: (_, _) => const Divider(),
                                itemBuilder: (_, index) {
                                  final client = matches[index];
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.person_outline,
                                      color: Colors.cyanAccent,
                                    ),
                                    title: Text(
                                      client.nombre,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    onTap: () => Navigator.pop(context, client),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    searchController.dispose();

    if (selected != null && mounted) {
      setState(() => selectedClient = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          prefixStyle: const TextStyle(
            color: Colors.white,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.orangeAccent,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Nuevo movimiento"),
          centerTitle: true,
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _introCard(),
            const SizedBox(height: 16),
            _sectionCard(
              title: "Tipo de movimiento",
              icon: Icons.swap_horiz,
              color: movementColor(movementType),
              children: [
                selectorMovimiento(),
                const SizedBox(height: 10),
                _smallHelp(
                  movementDescription(movementType),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: requiereCliente
                  ? "Envase y cliente"
                  : "Envase",
              icon: Icons.inventory_2,
              color: Colors.cyanAccent,
              children: [
                selectorTipoEnvase(),
                if (requiereCliente) ...[
                  const SizedBox(height: 12),
                  selectorCliente(),
                  const SizedBox(height: 10),
                  _smallHelp(
                    clienteHelp(),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  _smallHelp(
                    "Este movimiento se registra directamente contra el almacén. No se asocia a ningún cliente.",
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: "Detalle",
              icon: Icons.edit_note,
              color: Colors.orangeAccent,
              children: [
                campoCantidad(),
                if (muestraDepositoRecibido) ...[
                  const SizedBox(height: 12),
                  campoDepositoRecibido(),
                  const SizedBox(height: 10),
                  _smallHelp(
                    "Regístralo solo si el cliente realmente dejó una garantía. No es precio de venta.",
                  ),
                ],
                if (muestraDepositoDevuelto) ...[
                  const SizedBox(height: 12),
                  campoDepositoDevuelto(),
                  const SizedBox(height: 10),
                  _smallHelp(
                    "Indica el dinero que devuelves al cliente por esta devolución de envases. Puede ser cero o parcial.",
                  ),
                ],
                const SizedBox(height: 12),
                campoReferencia(),
              ],
            ),
            const SizedBox(height: 28),
            botonGuardar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget selectorCliente() {
    return InkWell(
      onTap: saving ? null : seleccionarCliente,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        isEmpty: selectedClient == null,
        decoration: const InputDecoration(
          labelText: "Cliente",
          suffixIcon: Icon(Icons.search),
        ),
        child: Text(
          selectedClient?.nombre ?? "Buscar y seleccionar cliente",
          style: TextStyle(
            color: selectedClient == null ? Colors.white54 : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget selectorTipoEnvase() {
    return DropdownButtonFormField<BinType>(
      initialValue: selectedType,
      isExpanded: true,
      dropdownColor: card,
      style: const TextStyle(
        color: Colors.white,
      ),
      items: types.map((type) {
        return DropdownMenuItem<BinType>(
          value: type,
          child: Text(
            type.nombre,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: saving
          ? null
          : (value) {
              setState(() {
                selectedType = value;
              });
            },
      decoration: const InputDecoration(
        labelText: "Tipo de envase",
      ),
    );
  }

  Widget selectorMovimiento() {
    return DropdownButtonFormField<String>(
      initialValue: movementType,
      isExpanded: true,
      dropdownColor: card,
      style: const TextStyle(
        color: Colors.white,
      ),
      items: const [
        DropdownMenuItem(
          value: "entrada",
          child: Text("Entrada al almacén"),
        ),
        DropdownMenuItem(
          value: "prestamo",
          child: Text("Prestar bins a cliente"),
        ),
        DropdownMenuItem(
          value: "devolucion",
          child: Text("Recibir devolución de bins"),
        ),
        DropdownMenuItem(
          value: "baja",
          child: Text("Baja de envases"),
        ),
      ],
      onChanged: saving
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                movementType = value;

                if (!requiereCliente) {
                  selectedClient = null;
                }

                if (!muestraDepositoRecibido) {
                  depositoRecibidoController.clear();
                }
                if (!muestraDepositoDevuelto) {
                  depositoDevueltoController.clear();
                }
              });
            },
      decoration: const InputDecoration(
        labelText: "Tipo de movimiento",
      ),
    );
  }

  Widget campoCantidad() {
    return TextField(
      controller: cantidadController,
      style: const TextStyle(
        color: Colors.white,
      ),
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Cantidad de envases",
        hintText: "Ej: 2, 10, 100",
      ),
    );
  }

  Widget campoDepositoRecibido() {
    return TextField(
      controller: depositoRecibidoController,
      style: const TextStyle(
        color: Colors.white,
      ),
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: const InputDecoration(
        labelText: "Garantía recibida",
        prefixText: "\$",
        hintText: "Ej: 140000",
      ),
    );
  }

  Widget campoDepositoDevuelto() {
    return TextField(
      controller: depositoDevueltoController,
      style: const TextStyle(
        color: Colors.white,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: "Garantía devuelta",
        prefixText: "\$",
        hintText: "Ej: 140000",
      ),
    );
  }

  Widget campoReferencia() {
    return TextField(
      controller: referenciaController,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: const InputDecoration(
        labelText: "Referencia",
        hintText: "Ej: Stock inicial, guía, nota interna",
      ),
    );
  }

  Widget botonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: saving ? null : saveMovement,
        icon: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          "Guardar ${movementLabel(movementType)}",
        ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEA580C),
            Color(0xFFEAB308),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.add_box,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Registra entradas al almacén, préstamos a clientes, devoluciones o bajas de envases físicos. Las ventas ya registran automáticamente los envases entregados al cliente.",
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

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _smallHelp(String text) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline,
          size: 18,
          color: Colors.white54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.3,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}
