import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/buddy_theme.dart';

/// Branded in-app splash while state finishes loading / for a calm first beat.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _rise = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onFinished?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [
                        Color(0xFF0A1416),
                        BuddyColors.night,
                        Color(0xFF122026),
                      ]
                    : const [
                        Color(0xFFE7F1EC),
                        BuddyColors.sand,
                        Color(0xFFF7EFE4),
                      ],
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: dark ? 0.18 : 0.35,
              child: Image.asset(
                'assets/brand/buddy_splash_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fade,
            child: AnimatedBuilder(
              animation: _rise,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _rise.value),
                  child: child,
                );
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: BuddyColors.moss.withValues(alpha: 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/brand/buddy_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Buddy',
                      style: GoogleFonts.fraunces(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        color: dark ? BuddyColors.nightText : BuddyColors.deep,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Companion for your day & deen',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: BuddyColors.sage,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
