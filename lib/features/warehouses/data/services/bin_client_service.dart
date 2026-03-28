import 'dart:convert';
import '../models/bin_client_model.dart';
import '../../../../core/services/api_service.dart';

class BinClientService {

  Future<List<BinClient>> getClients() async {

    final response = await ApiService.get("/bins/clientes/");

    print("STATUS CLIENTES BINS: ${response.statusCode}");
    print("BODY CLIENTES BINS: ${response.body}");

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);
      return data.map((e) => BinClient.fromJson(e)).toList();

    } else {

      throw Exception("Error loading clients");

    }

  }
}