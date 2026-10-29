// ===========================================================================
// demo_widgets.dart — Shared demo helpers used by all demo sections.
//
// The bc_ui_flutter package has no BcButton or BcCard (those are handled by
// Material/Cupertino primitives), so these wrappers give every demo a
// consistent visual frame and reduce boilerplate.
// ===========================================================================
library demo_widgets;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

/// A titled card that frames a single demo.
class DemoCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const DemoCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BcBox(
      padding: 20,
      border: true,
      borderRadius: BcTheme.radius,
      backgroundColor: BcBoxColorToken.card,
      child: BcYStack(
        gap: 12,
        children: [
          BcYStack(
            gap: 4,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BcTheme.mutedForeground,
                    ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// A section header at the top of each demo category page.
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 4,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BcTheme.mutedForeground,
              ),
        ),
      ],
    );
  }
}

/// A small colored swatch used in layout demos.
Widget colorSwatch(Color color, String label) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
