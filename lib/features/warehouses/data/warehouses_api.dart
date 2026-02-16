import '../../../core/http/http_client.dart';

class WarehousesApi {

  static Future<List<dynamic>> getClientes() async {

    final response = await HttpClient.get(
      '/api/bins/clientes/',
    );

    return response;

  }

}