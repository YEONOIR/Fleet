import 'package:flutter/material.dart';
import '../../components/owner_nav_bar.dart'; 
import 'owner_profile.dart';
import 'owner_home.dart';
import 'owner_notification.dart';
import 'owner_vehicle.dart';
import 'owner_schedule.dart';

class OwnerMainPage extends StatefulWidget {
  const OwnerMainPage({super.key});

  @override
  State<OwnerMainPage> createState() => _OwnerMainPageState();
}

class _OwnerMainPageState extends State<OwnerMainPage> {
  int _currentIndex = 0;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('initialIndex')) {
        _currentIndex = args['initialIndex'];
      }
      _isInit = true;
    }
  }

  // หน้าจอทั้ง 5 หน้าของ Owner
  final List<Widget> _pages = [
    OwnerHomePage(),
    OwnerVehiclePage(),
    OwnerSchedulePage(),
    OwnerNotificationPage(),
    OwnerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1.0),
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: OwnerNavBar(
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