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
    double simulatedDrivingSavings = (1.0 - _drivingReduction) * 120; 
    double simulatedPowerSavings = (1.0 - _electricityReduction) * 90;
    double totalSimulatedSavings = simulatedDrivingSavings + simulatedPowerSavings;
    
    double dynamicProjectedBurn = widget.currentEmissions - totalSimulatedSavings;
    if (dynamicProjectedBurn < 0) dynamicProjectedBurn = 0;

    // Calculate progress for the dynamic animation bar
    double progressValue = dynamicProjectedBurn / monthlyLimit;
    if (progressValue > 1.0) progressValue = 1.0;
    final bool isOverBudget = dynamicProjectedBurn > monthlyLimit;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Carbon Budget Optimization', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
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

                // --- UPGRADED: ANIMATED DYNAMIC HERO CARD ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Projected Monthly Burn', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('Limit: ${monthlyLimit.toStringAsFixed(0)} kg', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            dynamicProjectedBurn.toStringAsFixed(1),
                            style: TextStyle(
                              color: isOverBudget ? Colors.redAccent : const Color(0xFF52B788), 
                              fontSize: 40, 
                              fontWeight: FontWeight.bold, 
                              height: 1.0
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('kg CO₂', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Gliding Animation Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: progressValue),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 12,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(isOverBudget ? Colors.redAccent : const Color(0xFF52B788)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isOverBudget ? '⚠️ Exceeding Monthly Allowance' : '✅ Safe Zone', 
                        style: TextStyle(color: isOverBudget ? Colors.redAccent : const Color(0xFF52B788), fontSize: 13, fontWeight: FontWeight.bold)
                      ),
                    ],
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
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey[200]!)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune_rounded, color: Color(0xFF2D6A4F)),
                            const SizedBox(width: 8),
                            Text('Eco-Adjustment Simulator', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2D6A4F))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Drag the sliders to see how reducing your daily habits instantly drops your footprint projections.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                        const Divider(height: 32),

                        // Slider 1: Commute metrics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🚗 Vehicle Driving Commute', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('${(_drivingReduction * 100).toStringAsFixed(0)}% Usage', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F))),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xFF52B788), thumbColor: const Color(0xFF2D6A4F)),
                          child: Slider(
                            value: _drivingReduction,
                            min: 0.2,
                            max: 1.0,
                            onChanged: (val) => setState(() => _drivingReduction = val),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        // Slider 2: Home Utilities metrics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('⚡ Home Electricity Power', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('${(_electricityReduction * 100).toStringAsFixed(0)}% Usage', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(activeTrackColor: Colors.amber, thumbColor: Colors.amber[800]),
                          child: Slider(
                            value: _electricityReduction,
                            min: 0.2,
                            max: 1.0,
                            onChanged: (val) => setState(() => _electricityReduction = val),
                          ),
                        ),
                        
                        if (totalSimulatedSavings > 0) ...[
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Projected Savings Plan:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F))),
                              Text('-${totalSimulatedSavings.toStringAsFixed(1)} kg CO₂ / mo', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F), fontSize: 16)),
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

  Widget _buildTargetTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: TableBorder(horizontalInside: BorderSide(color: Colors.grey[100]!, width: 1)),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[50]),
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
        ),
      ),
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