import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carbon_provider.dart';

class LogActivitySheet extends StatefulWidget {
  final String userId;
  const LogActivitySheet({super.key, required this.userId});

  @override
  State<LogActivitySheet> createState() => _LogActivitySheetState();
}

class _LogActivitySheetState extends State<LogActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  
  // Track selected category details
  int _selectedCategoryId = 1;
  String _selectedUnit = "Miles";

  // Mock mapping that mirrors our MySQL database seeder definitions
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Gasoline Vehicle Travel', 'unit': 'Miles'},
    {'id': 2, 'name': 'Home Electricity Usage', 'unit': 'KWh'},
    {'id': 3, 'name': 'Short-Haul Flight Journey', 'unit': 'Hours'},
    {'id': 4, 'name': 'Dietary Meat Consumption', 'unit': 'Meals'},
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Avoids keyboard overlap on mobile
        top: 24, left: 24, right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track Carbon Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Dropdown Selector Component
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Activity Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat['id'],
                  child: Text(cat['name']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedUnit = _categories.firstWhere((c) => c['id'] == value)['unit'];
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Numerical Input Component
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Quantity consumed ($_selectedUnit)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.add_chart),
              ),
              validator: (value) {
                if (value == null || value.isEmpty || double.tryParse(value) == null) {
                  return 'Please enter a valid numeric value';
                }
                if (double.parse(value) <= 0) {
                  return 'Quantity must be greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button Action Controller
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final provider = Provider.of<CarbonProvider>(context, listen: false);
                    
                    bool success = await provider.logActivity(
                      userId: widget.userId,
                      categoryId: _selectedCategoryId,
                      quantity: double.parse(_quantityController.text),
                    );

                    if (mounted) {
                      if (success) {
                        Navigator.pop(context); // Close sheet on success
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🌱 Activity successfully added to your ledger!'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❌ Error saving transaction. Check your connection.'), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save Activity Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}