import 'package:flutter/material.dart';
import 'package:new_gotrip/view/history_screen.dart';
import 'package:new_gotrip/view/home_screen.dart';
import 'package:new_gotrip/view/navigation_screen.dart';
import 'package:new_gotrip/view/profile_screen.dart';

class Bottomnavigation extends StatefulWidget {
  final int initialIndex;

  const Bottomnavigation({super.key, this.initialIndex = 0});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    KeyedSubtree(key: ValueKey('home'), child: HomeScreen()),
    KeyedSubtree(key: ValueKey('history'), child: HistoryScreen()),
    KeyedSubtree(key: ValueKey('map'), child: NavigationScreen()),
    KeyedSubtree(key: ValueKey('profile'), child: ProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
