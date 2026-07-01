import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../models/bin_balance_model.dart';

class BinBalanceService {
  Future<List<BinBalance>> getBalance() async {
    final response = await ApiService.get("/bins/balance/");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => BinBalance.fromJson(e)).toList();
    }

    throw Exception("Error loading balance");
  }
}