import 'dart:convert';
import '../../../core/http/http_client.dart';

class WarehousesApi {

  static Future<List<dynamic>> getClientes() async {

    final response = await HttpClient.get(
      '/api/bins/clientes/',
    );

    // Verificar respuesta OK
    if (response.statusCode == 200) {

      // Convertir JSON string → List
      final data = jsonDecode(response.body);

      return data;

    } else {

      throw Exception(
        "Error cargando clientes: ${response.statusCode}"
      );

    }

  }

}
