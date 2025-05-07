import 'package:dio/dio.dart';
import 'package:stacked/stacked.dart';

import '../models/transactions_model.dart';
import 'api_service.dart';

class TransactionsService with ListenableServiceMixin {
  final ApiService _apiService = ApiService();

  final ReactiveValue<List<Transactions>> _transactions =
      ReactiveValue<List<Transactions>>([]);
  List<Transactions> get transactions => _transactions.value;
  TransactionsService() {
    listenToReactiveValues([_transactions]);
  }
  Future<List<Transactions>> getTransactions() async {
    try {
      final response = await _apiService.get('/transactions');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Transactions.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load transactions: Status Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load transactionshgghdssg: $e');
    }
  }

  Future<Transactions?> getTransactionById(int id) async {
    try {
      final Response response = await _apiService.get('/transactions/$id');

      if (response.statusCode == 200) {
        return Transactions.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null; // Transaction not found
      } else {
        throw Exception(
            'Failed to load transaction: Status Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load transaction: $e');
    }
  }

  Future<Transactions> createTransaction(Map<String, dynamic> data) async {
    try {
      final Response response =
          await _apiService.post('/transactions', data: data);

      if (response.statusCode == 201) {
        return Transactions.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create transaction: Status Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<Transactions> updateTransaction(
      int id, Map<String, dynamic> data) async {
    try {
      final Response response =
          await _apiService.put('/transactions/$id', data: data);

      if (response.statusCode == 200) {
        return Transactions.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update transaction: Status Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      final Response response = await _apiService.delete('/transactions/$id');

      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete transaction: Status Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
