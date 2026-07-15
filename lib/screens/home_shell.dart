import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import 'chat_screen.dart';
import 'focus_screen.dart';
import 'journal_screen.dart';
import 'salah_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    ChatScreen(),
    FocusScreen(),
    SalahScreen(),
    JournalScreen(),
    SettingsScreen(),
  ];

  void _goTo(int i) {
    setState(() => _index = i);
    context.read<BuddyState>().setActiveTab(i);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuddyState>();
    final dark = state.profile.darkMode;
    final unread = state.unreadChat;

    if (state.tabJump != null && state.tabJump != _index) {
      final jump = state.tabJump!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _index = jump);
        state.consumeTabJump();
        state.setActiveTab(jump);
      });
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        backgroundColor: dark
            ? BuddyColors.nightPanel
            : BuddyColors.sand.withValues(alpha: 0.96),
        indicatorColor: dark ? BuddyColors.nightMist : BuddyColors.mist,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 9 ? '9+' : '$unread'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 9 ? '9+' : '$unread'),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Buddy',
          ),
          const NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Focus',
          ),
          const NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'Salah',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Journal',
          ),
          const NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
