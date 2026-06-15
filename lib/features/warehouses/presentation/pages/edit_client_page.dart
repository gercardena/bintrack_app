import 'package:flutter/material.dart';

import '../../data/models/bin_client_model.dart';
import '../../data/services/bin_client_service.dart';

class EditClientPage extends StatefulWidget {
final BinClient client;

const EditClientPage({
super.key,
required this.client,
});

@override
State<EditClientPage> createState() =>
_EditClientPageState();
}

class _EditClientPageState
extends State<EditClientPage> {
final _formKey =
GlobalKey<FormState>();

final service = BinClientService();

late TextEditingController nombreController;
late TextEditingController rutController;
late TextEditingController emailController;
late TextEditingController telefonoController;
late TextEditingController direccionController;

@override
void initState() {
super.initState();

nombreController =
    TextEditingController(
  text: widget.client.nombre,
);

rutController =
    TextEditingController(
  text: widget.client.rut,
);

emailController =
    TextEditingController(
  text: widget.client.email,
);

telefonoController =
    TextEditingController(
  text: widget.client.telefono,
);

direccionController =
    TextEditingController(
  text: widget.client.direccion,
);

}

Future<void> saveClient() async {
if (!_formKey.currentState!
.validate()) {
return;
}


await service.updateClient(
  id: widget.client.id,
  nombre: nombreController.text,
  rut: rutController.text,
  email: emailController.text,
  telefono: telefonoController.text,
  direccion:
      direccionController.text,
  activo: widget.client.activo,
);

if (!mounted) return;

Navigator.pop(context, true);


}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
"Editar Cliente",
),
),
body: Padding(
padding:
const EdgeInsets.all(16),
child: Form(
key: _formKey,
child: ListView(
children: [
TextFormField(
controller:
nombreController,
decoration:
const InputDecoration(
labelText: "Nombre",
),
),


          const SizedBox(
            height: 12,
          ),

          TextFormField(
            controller:
                rutController,
            decoration:
                const InputDecoration(
              labelText: "RUT",
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextFormField(
            controller:
                emailController,
            decoration:
                const InputDecoration(
              labelText: "Email",
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextFormField(
            controller:
                telefonoController,
            decoration:
                const InputDecoration(
              labelText:
                  "Teléfono",
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextFormField(
            controller:
                direccionController,
            decoration:
                const InputDecoration(
              labelText:
                  "Dirección",
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          ElevatedButton(
            onPressed:
                saveClient,
            child: const Text(
              "Guardar Cambios",
            ),
          ),
        ],
      ),
    ),
  ),
);


}
}
