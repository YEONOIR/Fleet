import 'package:flutter/material.dart';
import 'staff_home.dart';
import 'staff_notifications.dart';
import 'staff_profile.dart';
import '../../components/staff_nav_bar.dart';

class StaffMainPage extends StatefulWidget {
  const StaffMainPage({super.key});

  @override
  State<StaffMainPage> createState() => _StaffMainPageState();
}

class _StaffMainPageState extends State<StaffMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StaffHomePage(),
    const StaffNotificationsPage(),
    const StaffProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: StaffNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
