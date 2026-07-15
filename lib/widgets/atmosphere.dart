import 'package:flutter/material.dart';

import '../theme/buddy_theme.dart';

class Atmosphere extends StatelessWidget {
  const Atmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [
            Color(0xFF0A1416),
            BuddyColors.night,
            Color(0xFF122026),
          ]
        : const [
            Color(0xFFE7F1EC),
            BuddyColors.sand,
            Color(0xFFF7EFE4),
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _Blob(
              color: (dark ? BuddyColors.sage : BuddyColors.sage)
                  .withValues(alpha: dark ? 0.12 : 0.18),
              size: 220,
            ),
          ),
          Positioned(
            bottom: 40,
            left: -60,
            child: _Blob(
              color: BuddyColors.warm.withValues(alpha: dark ? 0.08 : 0.12),
              size: 260,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class SoftPanel extends StatelessWidget {
  const SoftPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark
            ? BuddyColors.nightPanel.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: dark
            ? Border.all(color: BuddyColors.nightMist.withValues(alpha: 0.5))
            : null,
      ),
      child: child,
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
