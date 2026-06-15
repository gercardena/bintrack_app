import 'dart:convert';
import '../models/bin_client_model.dart';
import '../../../../core/services/api_service.dart';

class BinClientService {

Future<List<BinClient>> getClients() async {

  final response =
      await ApiService.get("/bins/clientes/");

  print(
    "STATUS CLIENTES BINS: ${response.statusCode}",
  );

  print(
    "BODY CLIENTES BINS: ${response.body}",
  );

  if (response.statusCode == 200) {

    List data = jsonDecode(response.body);

    return data
        .map(
          (e) => BinClient.fromJson(e),
        )
        .cast<BinClient>()
        .toList();

  } else {

    throw Exception(
      "Error loading clients",
    );

  }


}

Future createClient({
required String nombre,
required String rut,
required String email,
required String telefono,
required String direccion,
}) async {

final response = await ApiService.post(
  "/bins/clientes/",
  body: {
    "nombre": nombre,
    "rut": rut,
    "email": email,
    "telefono": telefono,
    "direccion": direccion,
    "activo": true,
  },
);

print(
  "CREATE CLIENT STATUS: ${response.statusCode}",
);

print(
  "CREATE CLIENT BODY: ${response.body}",
);

if (response.statusCode != 201) {
  throw Exception(
    "Error creando cliente",
  );
}

}

Future updateClient({
required int id,
required String nombre,
required String rut,
required String email,
required String telefono,
required String direccion,
required bool activo,
}) async {

final response = await ApiService.put(
  "/bins/clientes/$id/",
  body: {
    "nombre": nombre,
    "rut": rut,
    "email": email,
    "telefono": telefono,
    "direccion": direccion,
    "activo": activo,
  },
);

print(
  "UPDATE CLIENT STATUS: ${response.statusCode}",
);

print(
  "UPDATE CLIENT BODY: ${response.body}",
);

if (response.statusCode != 200) {
  throw Exception(
    "Error actualizando cliente",
  );
}

}

Future deleteClient(
int id,
) async {

final response = await ApiService.delete(
  "/bins/clientes/$id/",
);

print(
  "DELETE CLIENT STATUS: ${response.statusCode}",
);

if (response.statusCode != 204) {
  throw Exception(
    "Error eliminando cliente",
  );
}

}
}