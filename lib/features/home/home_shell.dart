import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../agenda/presentation/agenda_screen.dart';
import '../schedule/presentation/schedule_screen.dart';
import '../profile/presentation/profile_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  final Widget? child;
  const HomeShell({super.key, this.child});
  @override ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 1; // Default to schedule tab

  final _pages = const [
    AgendaScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: IndexedStack(index: _currentIndex, children: _pages)),
      NavigationBar(selectedIndex: _currentIndex, onDestinationSelected: (i) => setState(() => _currentIndex = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: '日程'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: '课表'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '我的'),
      ]),
    ]);
  }
}
