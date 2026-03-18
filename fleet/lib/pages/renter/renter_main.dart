import 'package:flutter/material.dart';
import '../../components/custom_nav_bar.dart';
import 'renter_home.dart';
import 'renter_your_rent.dart';
import 'renter_search.dart';
import 'renter_notifications.dart';
import 'renter_profile.dart';

class RenterMainPage extends StatefulWidget {
  const RenterMainPage({super.key});

  @override
  State<RenterMainPage> createState() => _RenterMainPageState();
}

class _RenterMainPageState extends State<RenterMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RenterHomePage(),
    RenterYourRentPage(),
    RenterSearchPage(),
    RenterNotificationsPage(),
    RenterProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavBar(
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
