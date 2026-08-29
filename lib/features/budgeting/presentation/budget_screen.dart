import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'budget_controller.dart';

/// Budget screen (US-13 core portion): amount/spent/remaining/progress
/// plus notification threshold toggles.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetControllerProvider);
    final controller = ref.read(budgetControllerProvider.notifier);
    final status = state.status;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: state.isLoading || status == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!status.hasBudgetConfigured)
                      Card(
                        child: ListTile(
                          key: const Key('budget-set-amount-button'),
                          title: const Text('No budget set for this month'),
                          subtitle: const Text('Tap to set one'),
                          onTap: () => _showSetAmountDialog(context, controller),
                        ),
                      )
                    else ...[
                      Text(
                        '₹${status.amountSpent.toStringAsFixed(2)} of ₹${status.budgetAmount.toStringAsFixed(2)}',
                        key: const Key('budget-amount-display'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        key: const Key('budget-progress-bar'),
                        value: (status.percentageUsed / 100).clamp(0, 1),
                      ),
                      const SizedBox(height: 8),
                      Text('Remaining: ₹${status.remainingAmount.toStringAsFixed(2)}'),
                      const SizedBox(height: 24),
                      Text('Notify me at:', style: Theme.of(context).textTheme.titleMedium),
                      _ThresholdSwitch(threshold: 50, keyName: 'budget-notify-50-toggle', controller: controller),
                      _ThresholdSwitch(threshold: 75, keyName: 'budget-notify-75-toggle', controller: controller),
                      _ThresholdSwitch(threshold: 90, keyName: 'budget-notify-90-toggle', controller: controller),
                      _ThresholdSwitch(threshold: 100, keyName: 'budget-notify-100-toggle', controller: controller),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  void _showSetAmountDialog(BuildContext context, BudgetController controller) {
    final textController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set monthly budget'),
        content: TextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(textController.text);
              if (amount != null) controller.setBudgetAmount(amount);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ThresholdSwitch extends StatefulWidget {
  const _ThresholdSwitch({required this.threshold, required this.keyName, required this.controller});

  final int threshold;
  final String keyName;
  final BudgetController controller;

  @override
  State<_ThresholdSwitch> createState() => _ThresholdSwitchState();
}

class _ThresholdSwitchState extends State<_ThresholdSwitch> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      key: Key(widget.keyName),
      title: Text('${widget.threshold}%'),
      value: _enabled,
      onChanged: (value) {
        setState(() => _enabled = value);
        widget.controller.updateThreshold(widget.threshold, value);
      },
    );
  }
}
