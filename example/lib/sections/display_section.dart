import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';
import '../demo_widgets.dart';

/// Display widgets: BcAvatar, BcBadge, BcStatistic, BcDescriptions, BcSteps, BcResult, BcEmpty.
class DisplaySection extends StatelessWidget {
  const DisplaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Display',
          subtitle: 'Avatars, badges, statistics, descriptions, steps, result states, and empty placeholders.',
        ),


        // -- BcAvatar --
        DemoCard(
          title: 'BcAvatar',
          description: 'Circular avatar with image fallback to initials.',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.center,
            children: [
              const BcAvatar(alt: 'Alice Anderson'),
              const BcAvatar(alt: 'Bob', fallback: 'BB'),
              const BcAvatar(size: BcComponentSize.sm, alt: 'Carol'),
              const BcAvatar(size: BcComponentSize.lg, alt: 'Dave'),
              const BcAvatar(),
            ],
          ),
        ),

        // -- BcBadge --
        DemoCard(
          title: 'BcBadge',
          description: 'Compact pill badge with variant token colors.',
          child: BcXStack(
            gap: 8,
            wrap: WrapAlignment.start,
            crossAxisAlignment: BcXStackAlign.center,
            children: [
              const BcBadge(label: 'Default'),
              const BcBadge(label: 'Primary', variant: BcComponentVariant.primary),
              const BcBadge(label: 'Secondary', variant: BcComponentVariant.secondary),
              const BcBadge(label: 'Destructive', variant: BcComponentVariant.destructive),
              const BcBadge(label: 'Outline', variant: BcComponentVariant.outline),
            ],
          ),
        ),
        // ── BcStatistic ──
        DemoCard(
          title: 'BcStatistic',
          description: 'Large value display with trend indicator and caption.',
          child: BcXStack(
            gap: 16,
            wrap: WrapAlignment.start,
            crossAxisAlignment: BcXStackAlign.start,
            children: [
              _statBox(BcStatistic(
                title: 'Total Revenue',
                value: '\$84,254',
                trend: BcStatisticTrend.up,
                caption: '+12.5% from last month',
              )),
              _statBox(BcStatistic(
                title: 'Active Users',
                value: '2,847',
                trend: BcStatisticTrend.up,
                caption: '+234 this week',
              )),
              _statBox(BcStatistic(
                title: 'Churn Rate',
                value: '3.2',
                suffix: '%',
                trend: BcStatisticTrend.down,
                caption: '-0.4% improvement',
              )),
              _statBox(BcStatistic(
                title: 'Avg. Order',
                prefix: '\$',
                value: '156.30',
                trend: BcStatisticTrend.neutral,
                caption: 'No change',
              )),
            ],
          ),
        ),

        // ── BcDescriptions ──
        DemoCard(
          title: 'BcDescriptions',
          description: 'Key-value description list with bordered layout.',
          child: BcDescriptions(
            title: 'Customer Details',
            bordered: true,
            data: const {
              'Name': 'Jane Cooper',
              'Email': 'jane.cooper@example.com',
              'Phone': '+1 (555) 123-4567',
              'Company': 'Acme Corporation',
              'Role': 'Administrator',
              'Status': 'Active',
              'Member since': '2023-08-15',
              'Last login': '2026-06-25 14:32 UTC',
            },
          ),
        ),

        // ── BcSteps ──
        DemoCard(
          title: 'BcSteps',
          description: 'Stepper navigation with clickable steps.',
          child: const _StepsDemo(),
        ),

        // ── BcResult ──
        DemoCard(
          title: 'BcResult',
          description: 'Status result pages (success, error, warning, info).',
          child: BcXStack(
            gap: 12,
            wrap: WrapAlignment.start,
            crossAxisAlignment: BcXStackAlign.start,
            children: [
              _resultBox(BcResult(
                status: BcResultStatus.success,
                title: 'Payment Successful',
                subtitle: 'Your payment has been processed.',
              )),
              _resultBox(BcResult(
                status: BcResultStatus.error,
                title: 'Payment Failed',
                subtitle: 'Please try again.',
              )),
              _resultBox(BcResult(
                status: BcResultStatus.warning,
                title: 'Pending Review',
                subtitle: 'Awaiting approval.',
              )),
              _resultBox(BcResult(
                status: BcResultStatus.info,
                title: 'New Feature',
                subtitle: 'Check out what\'s new.',
              )),
            ],
          ),
        ),

        // ── BcEmpty ──
        DemoCard(
          title: 'BcEmpty',
          description: 'Empty state placeholder with icon, message, and action.',
          child: BcEmpty(
            icon: const Icon(Icons.inbox_outlined),
            message: 'No items found',
            action: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(BcStatistic stat) {
    return BcBox(
      padding: 16,
      border: true,
      borderRadius: BcTheme.radius,
      backgroundColor: BcBoxColorToken.card,
      child: stat,
    );
  }

  Widget _resultBox(BcResult result) {
    return SizedBox(
      width: 200,
      child: BcBox(
        padding: 16,
        border: true,
        borderRadius: BcTheme.radius,
        backgroundColor: BcBoxColorToken.card,
        child: result,
      ),
    );
  }
}

class _StepsDemo extends StatefulWidget {
  const _StepsDemo();

  @override
  State<_StepsDemo> createState() => _StepsDemoState();
}

class _StepsDemoState extends State<_StepsDemo> {
  int _current = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BcSteps(
          steps: const ['Account', 'Profile', 'Preferences', 'Confirm'],
          current: _current,
          clickable: true,
          onStepChange: (index, _) => setState(() => _current = index),
        ),
        const SizedBox(height: 16),
        BcXStack(
          gap: 8,
          crossAxisAlignment: BcXStackAlign.center,
          children: [
            ElevatedButton(
              onPressed: _current > 0 ? () => setState(() => _current--) : null,
              child: const Text('Previous'),
            ),
            ElevatedButton(
              onPressed: _current < 3 ? () => setState(() => _current++) : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
