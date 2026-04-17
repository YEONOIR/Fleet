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
  int _rentTabIndex = 0;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        if (args.containsKey('mainIndex')) {
          _currentIndex = args['mainIndex'];
        } else if (args.containsKey('initialIndex')) {
          _currentIndex = args['initialIndex'];
        }

        if (args.containsKey('tabIndex')) {
          _rentTabIndex = args['tabIndex'];
        }
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const RenterHomePage(),
      RenterYourRentPage(initialIndex: _rentTabIndex),
      const RenterSearchPage(),
      const RenterNotificationsPage(),
      const RenterProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
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
