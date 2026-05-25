import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/carbon_summary_model.dart';

class CarbonProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  CarbonSummary? _summary;
  List<dynamic> _insights = [];
  List<dynamic> _badges = [];
  bool _isLoading = false;
  String? _errorMessage;

  CarbonSummary? get summary => _summary;
  List<dynamic> get insights => _insights;
  List<dynamic> get badges => _badges;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardSummary(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summaryResponse = await _apiClient.dio.get('/summary/$userId');
      final insightsResponse = await _apiClient.dio.get('/insights/$userId');
      final badgesResponse = await _apiClient.dio.get('/badges/$userId');

      if (summaryResponse.statusCode == 200 && 
          insightsResponse.statusCode == 200 && 
          badgesResponse.statusCode == 200) {
        
        _summary = CarbonSummary.fromJson(summaryResponse.data);
        _insights = insightsResponse.data;
        _badges = badgesResponse.data;
      } else {
        _errorMessage = "Failed to synchronize system analytics.";
      }
    } catch (e) {
      _errorMessage = "Cannot connect to the server. Is the backend active?";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logActivity({
    required String userId,
    required int categoryId,
    required double quantity,
  }) async {
    try {
      final response = await _apiClient.dio.post('/logs', data: {
        'userId': userId,
        'categoryId': categoryId,
        'quantity': quantity,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchDashboardSummary(userId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}