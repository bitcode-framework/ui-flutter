library bc_pagination;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

class BcPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int siblingCount;
  final bool showFirstLast;
  final bool showPrevNext;
  final bool disabled;
  final BcChangeHandler<int>? onPageChange;

  const BcPagination({
    super.key,
    this.currentPage = 1,
    this.totalPages = 1,
    this.siblingCount = 1,
    this.showFirstLast = true,
    this.showPrevNext = true,
    this.disabled = false,
    this.onPageChange,
  });

  void _goTo(int page) {
    if (disabled) return;
    if (page < 1 || page > totalPages) return;
    onPageChange?.call(
      page,
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  List<int> _computePages() {
    if (totalPages <= 0) return [1];
    final pages = <int>[];
    final left = (currentPage - siblingCount).clamp(2, totalPages);
    final right = (currentPage + siblingCount).clamp(2, totalPages - 1);

    pages.add(1);
    if (left > 2) pages.add(-1);
    for (var i = left; i <= right; i++) {
      pages.add(i);
    }
    if (right < totalPages - 1) pages.add(-2);
    if (totalPages > 1) pages.add(totalPages);

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pagination',
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final children = <Widget>[];

    if (showFirstLast) {
      children.add(_buildControl(
        key: 'bc-pagination-first',
        label: 'First',
        icon: Icons.first_page,
        onTap: currentPage == 1 || disabled ? null : () => _goTo(1),
        enabled: currentPage != 1 && !disabled,
      ));
    }

    if (showPrevNext) {
      children.add(_buildControl(
        key: 'bc-pagination-prev',
        label: 'Prev',
        icon: Icons.chevron_left,
        onTap: currentPage == 1 || disabled ? null : () => _goTo(currentPage - 1),
        enabled: currentPage != 1 && !disabled,
      ));
    }

    for (final p in _computePages()) {
      if (p < 0) {
        children.add(_buildEllipsis());
      } else {
        children.add(_buildPageButton(p));
      }
    }

    if (showPrevNext) {
      children.add(_buildControl(
        key: 'bc-pagination-next',
        label: 'Next',
        icon: Icons.chevron_right,
        onTap: currentPage >= totalPages || disabled
            ? null
            : () => _goTo(currentPage + 1),
        enabled: currentPage < totalPages && !disabled,
      ));
    }

    if (showFirstLast) {
      children.add(_buildControl(
        key: 'bc-pagination-last',
        label: 'Last',
        icon: Icons.last_page,
        onTap: currentPage >= totalPages || disabled
            ? null
            : () => _goTo(totalPages),
        enabled: currentPage < totalPages && !disabled,
      ));
    }

    return children;
  }

  Widget _buildControl({
    required String key,
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return FilledButton(
      key: Key(key),
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: BcTheme.secondary,
        foregroundColor: BcTheme.secondaryForeground,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(36, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;

    return FilledButton(
      key: Key('bc-pagination-page-$page'),
      onPressed: disabled ? null : () => _goTo(page),
      style: FilledButton.styleFrom(
        backgroundColor:
            isActive ? BcTheme.primary : BcTheme.secondary,
        foregroundColor:
            isActive ? BcTheme.primaryForeground : BcTheme.secondaryForeground,
        padding: EdgeInsets.zero,
        minimumSize: const Size(36, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text('$page'),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      key: const Key('bc-pagination-ellipsis'),
      width: 36,
      height: 36,
      alignment: Alignment.center,
      child: const Text(
        '...',
        style: TextStyle(
          color: BcTheme.mutedForeground,
          fontSize: 14,
        ),
      ),
    );
  }
}
