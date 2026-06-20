import 'dart:convert';
import '../models/inventory_model.dart';
import '../../../../core/services/api_service.dart';

class InventoryService {

  Future<List<Inventory>> getInventory() async {

    final response = await ApiService.get("/inventario/");

    print("INVENTORY STATUS: ${response.statusCode}");
    print("INVENTORY BODY: ${response.body}");

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data.map((e) => Inventory.fromJson(e)).toList();

    } else {

      throw Exception("Error loading inventory");

    }
  }
}