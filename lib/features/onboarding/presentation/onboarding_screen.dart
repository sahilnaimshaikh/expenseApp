import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_controller.dart';

/// First-launch onboarding wizard (stories.md US-01). Collects currency
/// (defaulting to INR) and an optional initial monthly budget, per BR-9.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Expense Tracker',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Let\'s get your account set up — it only takes a moment.'),
              const SizedBox(height: 32),
              TextField(
                key: const Key('onboarding-currency-input'),
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  helperText: 'Defaults to INR if left blank.',
                ),
                controller: TextEditingController(text: state.currency),
                onChanged: controller.setCurrency,
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('onboarding-budget-input'),
                decoration: const InputDecoration(
                  labelText: 'Initial monthly budget (optional)',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: controller.setBudgetAmountText,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('onboarding-skip-budget-button'),
                      onPressed: state.isSubmitting
                          ? null
                          : () async {
                              final success = await controller.submit(skipBudget: true);
                              if (success && context.mounted) context.go('/');
                            },
                      child: const Text('Skip Budget'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      key: const Key('onboarding-submit-button'),
                      onPressed: state.isSubmitting
                          ? null
                          : () async {
                              final success = await controller.submit(skipBudget: false);
                              if (success && context.mounted) context.go('/');
                            },
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
