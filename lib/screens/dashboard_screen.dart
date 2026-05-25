import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carbon_provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'carbon_pie_chart.dart';
import 'log_activity_sheet.dart';
import 'budget_plan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activeUserId = authProvider.userId;
      if (activeUserId != null) {
        Provider.of<CarbonProvider>(context, listen: false).fetchDashboardSummary(activeUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTracker Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black87),
            tooltip: 'Log Out',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CarbonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authCtx = Provider.of<AuthProvider>(context, listen: false);
                      if (authCtx.userId != null) {
                        provider.fetchDashboardSummary(authCtx.userId!);
                      }
                    },
                    child: const Text('Retry Connection'),
                  )
                ],
              ),
            );
          }

          final data = provider.summary;
          if (data == null) {
            return const Center(child: Text('No data records found.'));
          }

          double consumptionPercentage = data.totalEmissionsToDate / data.annualCarbonGoal;
          if (consumptionPercentage > 1.0) consumptionPercentage = 1.0;

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 700;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back, ${data.userName} 👋', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        
                        Text('Actionable Sustainability Insights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildInsightsSection(context, provider.insights),
                        const SizedBox(height: 24),
                        
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: _buildProgressCard(context, data, consumptionPercentage)),
                              const SizedBox(width: 24),
                              Expanded(flex: 3, child: _buildMetricsCard(context, data)),
                            ],
                          )
                        else ...[
                          _buildProgressCard(context, data, consumptionPercentage),
                          const SizedBox(height: 24),
                          _buildMetricsCard(context, data),
                        ],
                        
                        const SizedBox(height: 32),
                        Text('Recent Environmental Logs', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildLedgerList(context, data),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => LogActivitySheet(userId: authProvider.userId ?? ""),
          );
        },
        label: const Text('Log Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context, List<dynamic> insights) {
  final theme = Theme.of(context);
  
  if (insights.isEmpty) {
    return const SizedBox(
      height: 40,
      child: Text('Calculating environmental trends...', style: TextStyle(color: Colors.grey)),
    );
  }
  
  return SizedBox(
    height: 170,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final card = insights[index];
        final isHigh = card['impactLevel'] == 'HIGH';
        
        return Container(
          width: 320,
          margin: const EdgeInsets.only(right: 16, bottom: 4),
          child: Card(
            elevation: 3,
            color: isHigh ? const Color(0xFFFFF3F3) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isHigh ? Colors.redAccent.withOpacity(0.5) : Colors.transparent,
                width: 1
              )
            ),
            // Make the entire card body interactive with a Material splash ink ripple effect
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleInsightTap(context, card['title']), // Triggers click action routing logic
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(card['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Icon(
                              isHigh ? Icons.warning_amber_rounded : Icons.lightbulb_outline,
                              color: isHigh ? Colors.red : Colors.green
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card['description'],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Text(
                      "${card['actionButtonText']} →",
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildProgressCard(BuildContext context, dynamic data, double percentage) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Annual Carbon Budget Allocation', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 16,
                    backgroundColor: Colors.grey[200],
                    color: percentage >= 0.85 ? Colors.redAccent : const Color(0xFF2E7D32),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(percentage * 100).toStringAsFixed(1)}%', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Consumed', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '${data.totalEmissionsToDate.toStringAsFixed(1)} kg / ${data.annualCarbonGoal.toStringAsFixed(0)} kg CO₂ Limit',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context, dynamic data) {
    final theme = Theme.of(context);
    double remaining = data.annualCarbonGoal - data.totalEmissionsToDate;
    if (remaining < 0) remaining = 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ledger Summary', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 24),
            _buildMetricRow(context, 'Remaining Allowance', '${remaining.toStringAsFixed(1)} kg', Colors.blue),
            const Divider(height: 24),
            _buildMetricRow(context, 'Total Logged Entries', '${data.activityHistory.length} activities', theme.colorScheme.primary),
            const Divider(height: 24),
            Text('Footprint Breakdown By Source', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600])),
            const SizedBox(height: 16),
            CarbonPieChart(history: data.activityHistory),
            const SizedBox(height: 24),
            Text('Earned Sustainability Badges', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildBadgesGrid(context, Provider.of<CarbonProvider>(context).badges),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context, List<dynamic> earnedBadges) {
    final theme = Theme.of(context);
    
    final List<Map<String, dynamic>> badgeCatalog = [
      {'code': 'FRESH_START', 'title': 'First Eco Step', 'desc': 'Logged your first activity entry', 'icon': Icons.spa_rounded, 'color': Colors.green},
      {'code': 'POWER_SAVER', 'title': 'Grid Guardian', 'desc': 'Logged 3 utility metrics successfully', 'icon': Icons.bolt_rounded, 'color': Colors.amber},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badgeCatalog.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 90,
      ),
      itemBuilder: (context, index) {
        final item = badgeCatalog[index];
        final bool isUnlocked = earnedBadges.any((b) => b['badgeCode'] == item['code']);

        return Card(
          elevation: isUnlocked ? 2 : 0,
          color: isUnlocked ? Colors.white : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isUnlocked ? item['color'].withOpacity(0.3) : Colors.grey[300]!)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isUnlocked ? item['color'].withOpacity(0.1) : Colors.grey[300],
                  child: Icon(item['icon'], color: isUnlocked ? item['color'] : Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isUnlocked ? Colors.black87 : Colors.grey[500])),
                      const SizedBox(height: 2),
                      Text(item['desc'], style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(BuildContext context, String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildLedgerList(BuildContext context, dynamic data) {
    if (data.activityHistory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No carbon activities logged yet. Get started tracking!')),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.activityHistory.length,
      itemBuilder: (context, index) {
        final log = data.activityHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(log.categoryName).withOpacity(0.1),
              child: Icon(_getCategoryIcon(log.categoryName), color: _getCategoryColor(log.categoryName)),
            ),
            title: Text(log.categoryName.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Amount: ${log.quantity} ${log.unit.toLowerCase()}'),
            trailing: Text('+${log.calculatedCo2.toStringAsFixed(1)} kg CO₂', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        );
      },
    );
  }

        void _handleInsightTap(BuildContext context, String title) {
    if (title.contains('Budget')) {
        
        // Fetch current carbon provider values safely
        final provider = Provider.of<CarbonProvider>(context, listen: false);
        final totalEmitted = provider.summary?.totalEmissionsToDate ?? 0.0;
        final totalGoal = provider.summary?.annualCarbonGoal ?? 3000.0;

        // Route user directly to our interactive simulator layout screen
        Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => BudgetPlanScreen(
            currentEmissions: totalEmitted,
            annualGoal: totalGoal,
            ),
        ),
        );

    } else if (title.contains('Alternative') || title.contains('Plate')) {
        _showGreenRecipesModal(context);
    }
    }


        void _showGreenRecipesModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
        return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    const Text('🍃 Low-Carbon Culinary Swaps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
                ),
                const SizedBox(height: 8),
                const Text('Swapping meat logs for plant-based choices drastically reduces household carbon ledger footprints.', style: TextStyle(color: Colors.grey)),
                const Divider(height: 32),
                
                _buildRecipeTile('Spiced Chickpea & Avocado Wrap', 'Saves ~2.1 kg CO₂ compared to beef burger variants'),
                _buildRecipeTile('Creamy Coconut Lentil Curry', 'Zero emission heating factors. Rich in proteins'),
                _buildRecipeTile('Zesty Quinoa Salad Bowl', 'Uses local sourcing distribution networks to drop transportation footprints'),
                
                const SizedBox(height: 16),
            ],
            ),
        );
        },
    );
    }

    Widget _buildRecipeTile(String name, String sub) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: const Icon(Icons.restaurant_menu_rounded, color: Colors.green),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
    );
    }

  IconData _getCategoryIcon(String name) {
    if (name.contains('VEHICLE')) return Icons.directions_car;
    if (name.contains('ELECTRICITY')) return Icons.bolt;
    if (name.contains('FLIGHT')) return Icons.flight;
    return Icons.restaurant;
  }

  Color _getCategoryColor(String name) {
    if (name.contains('VEHICLE')) return Colors.orange;
    if (name.contains('ELECTRICITY')) return Colors.amber;
    if (name.contains('FLIGHT')) return Colors.blue;
    return Colors.red;
  }
}