class CarbonSummary {
  final String userName;
  final double annualCarbonGoal;
  final double totalEmissionsToDate;
  final List<ActivityLog> activityHistory;

  CarbonSummary({
    required this.userName,
    required this.annualCarbonGoal,
    required this.totalEmissionsToDate,
    required this.activityHistory,
  });

  factory CarbonSummary.fromJson(Map<String, dynamic> json) {
    return CarbonSummary(
      userName: json['userName'] ?? '',
      annualCarbonGoal: (json['annualCarbonGoal'] as num).toDouble(),
      totalEmissionsToDate: (json['totalEmissionsToDate'] as num).toDouble(),
      activityHistory: (json['activityHistory'] as List? ?? [])
          .map((item) => ActivityLog.fromJson(item))
          .toList(),
    );
  }
}

class ActivityLog {
  final int id;
  final String categoryName;
  final String unit;
  final double quantity;
  final double calculatedCo2;
  final DateTime loggedAt;

  ActivityLog({
    required this.id,
    required this.categoryName,
    required this.unit,
    required this.quantity,
    required this.calculatedCo2,
    required this.loggedAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] ?? 0,
      categoryName: json['category']?['name'] ?? 'Unknown',
      unit: json['category']?['unit'] ?? 'Units',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      calculatedCo2: (json['calculatedCo2'] as num?)?.toDouble() ?? 0.0,
      loggedAt: DateTime.parse(json['loggedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}