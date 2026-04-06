import 'dart:convert';
import '../models/bin_balance_model.dart';
import '../../../../core/services/api_service.dart';

class BinBalanceService {

  Future<List<BinBalance>> getBalance() async {

    final response = await ApiService.get("/bins/balance/");

    print("STATUS BALANCE: ${response.statusCode}");
    print("BODY BALANCE: ${response.body}");

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data.map((e) => BinBalance.fromJson(e)).toList();

    } else {

      throw Exception("Error loading balance");

    }
  }
}