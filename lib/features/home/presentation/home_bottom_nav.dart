import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../theme/ryadom_buttons.dart';

enum HomeTab { radar, requests, profile }

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final HomeTab current;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: RyadomGlassSurface(
        variant: RyadomGlassVariant.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _HomeBottomNavItem(
                  icon: Icons.radar_rounded,
                  label: l10n.navRadar,
                  isSelected: current == HomeTab.radar,
                  onTap: () => onSelected(HomeTab.radar),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HomeBottomNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: l10n.navRequests,
                  isSelected: current == HomeTab.requests,
                  onTap: () => onSelected(HomeTab.requests),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HomeBottomNavItem(
                  icon: Icons.person_rounded,
                  label: l10n.navProfile,
                  isSelected: current == HomeTab.profile,
                  onTap: () => onSelected(HomeTab.profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBottomNavItem extends StatelessWidget {
  const _HomeBottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.72) ??
        const Color(0xFF6E7E79);
    final isDark = theme.brightness == Brightness.dark;
    final selectedText = isDark ? theme.colorScheme.onPrimary : Colors.white;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: isSelected ? selectedText : muted),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: 12,
            height: 1,
            color: isSelected ? selectedText : muted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );

    if (!isSelected) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: RyadomButtons.heightCompact + 8,
            child: Center(child: content),
          ),
        ),
      );
    }

    return RyadomGlassSurface(
      variant: RyadomGlassVariant.primary,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.12),
          child: SizedBox(
            height: RyadomButtons.heightCompact + 8,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}