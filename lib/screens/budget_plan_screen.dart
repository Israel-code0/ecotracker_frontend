import 'package:flutter/material.dart';

class BudgetPlanScreen extends StatefulWidget {
  final double currentEmissions;
  final double annualGoal;

  const BudgetPlanScreen({
    super.key,
    required this.currentEmissions,
    required this.annualGoal,
  });

  @override
  State<BudgetPlanScreen> createState() => _BudgetPlanScreenState();
}

class _BudgetPlanScreenState extends State<BudgetPlanScreen> {
  // Simulator slider state values (Percentage of current lifestyle habits)
  double _drivingReduction = 1.0;     // 1.0 means 100% (No change)
  double _electricityReduction = 1.0; // 1.0 means 100% (No change)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Core math formulas for predictive tracking
    double monthlyLimit = widget.annualGoal / 12;
    
    // Simulate savings based on interactive slider inputs
    // Assuming typical category weights for local testing projections
    double simulatedDrivingSavings = (1.0 - _drivingReduction) * 120; 
    double simulatedPowerSavings = (1.0 - _electricityReduction) * 90;
    double totalSimulatedSavings = simulatedDrivingSavings + simulatedPowerSavings;
    double dynamicProjectedBurn = widget.currentEmissions - totalSimulatedSavings;
    if (dynamicProjectedBurn < 0) dynamicProjectedBurn = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Budget Optimization', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget Allocation Strategy', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Manage your consumption burn rates to extend your annual target limit balance.', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),

                // Card: Monthly target tracking card status metrics
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Monthly Allowance', '${monthlyLimit.toStringAsFixed(0)} kg'),
                        Container(width: 1, height: 50, color: Colors.grey[300]),
                        _buildStatColumn('Current Projection', '${dynamicProjectedBurn.toStringAsFixed(1)} kg', 
                          color: dynamicProjectedBurn > monthlyLimit ? Colors.redAccent : Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Table Component: Breakdown Allocation Targets
                Text('Target Category Budgets', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildTargetTable(),
                const SizedBox(height: 32),

                // Interactive Simulator Segment
                Card(
                  color: const Color(0xFFF4F9F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xC0C8E6C9))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune_rounded, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('Eco-Adjustment Lifestyle Simulator', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[900])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Drag the adjustments sliders below to see how reducing your daily habits drops your footprint projections instantly!', style: TextStyle(fontSize: 13, color: Colors.black54)),
                        const Divider(height: 32),

                        // Slider 1: Commute metrics
                        Text('🚗 Vehicle Driving Commute: ${( _drivingReduction * 100).toStringAsFixed(0)}% of normal usage', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Slider(
                          value: _drivingReduction,
                          min: 0.2,
                          max: 1.0,
                          activeColor: Colors.green,
                          inactiveColor: Colors.green.withOpacity(0.2),
                          onChanged: (val) => setState(() => _drivingReduction = val),
                        ),
                        
                        // Slider 2: Home Utilities metrics
                        Text('⚡ Home Electricity Power: ${( _electricityReduction * 100).toStringAsFixed(0)}% of normal usage', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Slider(
                          value: _electricityReduction,
                          min: 0.2,
                          max: 1.0,
                          activeColor: Colors.green,
                          inactiveColor: Colors.green.withOpacity(0.2),
                          onChanged: (val) => setState(() => _electricityReduction = val),
                        ),
                        
                        if (totalSimulatedSavings > 0) ...[
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Projected Savings Plan:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              Text('-${totalSimulatedSavings.toStringAsFixed(1)} kg CO₂ / mo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String val, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
      ],
    );
  }

  Widget _buildTargetTable() {
    return Table(
      border: TableBorder(horizontalInside: BorderSide(color: Colors.grey[200]!, width: 1)),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: const [
            Padding(padding: EdgeInsets.all(12), child: Text('Sector Category', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('Target Limit', style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(12), child: Text('Status Zone', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        _buildTableRowData('🚗 Vehicle Commuting', '150 kg', 'Safe Zone', Colors.green),
        _buildTableRowData('⚡ Grid Utilities', '100 kg', 'High Alert ⚠️', Colors.orange),
        _buildTableRowData('🍔 Dietary Footprint', '120 kg', 'Safe Zone', Colors.green),
      ],
    );
  }

  TableRow _buildTableRowData(String sector, String limit, String status, Color statusColor) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(sector)),
        Padding(padding: const EdgeInsets.all(12), child: Text(limit)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}