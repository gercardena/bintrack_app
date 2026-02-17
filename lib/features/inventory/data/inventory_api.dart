import '../../../core/http/http_client.dart';
import 'dart:convert';

class InventoryApi {

  /// Obtener inventario
  static Future<List<dynamic>> getInventory() async {

    final response = await HttpClient.get(
      '/api/inventario/',
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data;

    } else {

      throw Exception('Error loading inventory');

    }
  }
}
