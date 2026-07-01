import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../models/inventory_model.dart';

class InventoryService {
  Future<List<Inventory>> getInventory() async {
    final response = await ApiService.get("/inventario/");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Inventory.fromJson(e)).toList();
    }

    throw Exception("Error loading inventory");
  }
}