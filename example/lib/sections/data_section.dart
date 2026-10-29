// Data display demo — BcDataTable, BcDescriptions, BcStatistic, BcList.
library data_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_data.dart';
import '../demo_widgets.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final people = Person.sample;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Data Display',
          subtitle: 'BcDataTable, BcDescriptions, and BcStatistic widgets.',
        ),
        const SizedBox(height: 24),

        // BcDataTable
        DemoCard(
          title: 'BcDataTable',
          description: 'Sortable, selectable data table with row tap actions.',
          child: BcBox(
            border: true,
            borderRadius: BcTheme.radius,
            padding: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('Team Members',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const Spacer(),
                      Text('${people.length} records',
                          style: const TextStyle(
                              color: BcTheme.mutedForeground, fontSize: 13)),
                    ],
                  ),
                ),
                BcDataTable<Person>(
                  columns: [
                    BcDataColumn(
                      label: 'Name',
                      sortable: true,
                      cellBuilder: (ctx, p) => Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: BcTheme.primary,
                            child: Text(
                              p.name.substring(0, 1),
                              style: const TextStyle(
                                  color: BcTheme.primaryForeground,
                                  fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(p.name),
                        ],
                      ),
                    ),
                    BcDataColumn(
                      label: 'Email',
                      sortable: false,
                      cellBuilder: (ctx, p) => Text(p.email,
                          style: const TextStyle(
                              color: BcTheme.mutedForeground)),
                    ),
                    BcDataColumn(
                      label: 'Dept',
                      sortable: true,
                      cellBuilder: (ctx, p) => Text(p.department),
                    ),
                    BcDataColumn(
                      label: 'Age',
                      numeric: true,
                      sortable: true,
                      cellBuilder: (ctx, p) => Text('${p.age}'),
                    ),
                  ],
                  rows: people,
                  sortable: true,
                  showCheckboxColumn: true,
                  onRowTap: (p) => BcDialog.show(
                    context: context,
                    title: p.name,
                    content: BcDescriptions(
                      bordered: true,
                      data: {
                        'Email': p.email,
                        'Department': p.department,
                        'Age': '${p.age}',
                        'ID': '#${p.id}',
                      },
                    ),
                    confirmText: 'Close',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // BcDescriptions
        DemoCard(
          title: 'BcDescriptions',
          description: 'Key-value description list with optional border.',
          child: BcDescriptions(
            title: 'Customer Details',
            bordered: true,
            data: {
              'Name': 'Jane Cooper',
              'Email': 'jane.cooper@example.com',
              'Phone': '+1 (555) 123-4567',
              'Company': 'Acme Corporation',
              'Role': 'Administrator',
              'Status': 'Active',
              'Member since': '2023-08-15',
            },
          ),
        ),
        const SizedBox(height: 24),

        // BcStatistic
        DemoCard(
          title: 'BcStatistic',
          description: 'Large value display with trend indicator.',
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _statItem(
                const BcStatistic(
                  title: 'Total Revenue',
                  value: '\$84,254',
                  trend: BcStatisticTrend.up,
                  caption: '+12.5% from last month',
                ),
              ),
              _statItem(
                const BcStatistic(
                  title: 'Active Users',
                  value: '2,847',
                  trend: BcStatisticTrend.up,
                  caption: '+234 this week',
                ),
              ),
              _statItem(
                const BcStatistic(
                  title: 'Churn Rate',
                  value: '3.2',
                  suffix: '%',
                  trend: BcStatisticTrend.down,
                  caption: '-0.4% improvement',
                ),
              ),
              _statItem(
                const BcStatistic(
                  title: 'Avg. Order',
                  prefix: '\$',
                  value: '156.30',
                  trend: BcStatisticTrend.neutral,
                  caption: 'No change',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -- BcChip --
        DemoCard(
          title: 'BcChip',
          description: 'Compact tag chips with 6 variants, avatar, and removable.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BcChip(label: 'Default'),
              BcChip(label: 'Primary', variant: BcChipVariant.primary),
              BcChip(label: 'Success', variant: BcChipVariant.success),
              BcChip(label: 'Warning', variant: BcChipVariant.warning),
              BcChip(label: 'Destructive', variant: BcChipVariant.destructive),
              BcChip(label: 'Info', variant: BcChipVariant.info),
              BcChip(label: 'Avatar', avatar: 'AB'),
              BcChip(label: 'Removable', removable: true),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -- BcList --
        DemoCard(
          title: 'BcList',
          description: 'Material list view with optional leading/trailing builders and tap handler.',
          child: SizedBox(
            height: 260,
            child: BcList<String>(
              shrinkWrap: true,
              items: const ['Inbox', 'Drafts', 'Sent', 'Spam', 'Trash'],
              leadingBuilder: (_, item) => const Icon(Icons.mail_outline, size: 20),
              trailingBuilder: (_, item) => const Icon(Icons.chevron_right, size: 20),
              onTap: (item) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped: $item'),
                  duration: const Duration(milliseconds: 800),
                ),
              ),
              itemBuilder: (_, item, __) => Text(item),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statItem(BcStatistic stat) {
    return BcBox(
      padding: 16,
      border: true,
      borderRadius: BcTheme.radius,
      backgroundColor: BcBoxColorToken.card,
      child: SizedBox(
        width: 200,
        child: stat,
      ),
    );
  }
}
