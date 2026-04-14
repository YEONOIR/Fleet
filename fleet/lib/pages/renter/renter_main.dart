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
  int _rentTabIndex = 0; // 💡 สร้างตัวแปรมารับค่าแท็บด้านบนของหน้า Your Rent
  bool _isInit = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args != null) {
        // 💡 1. รับค่าเมนูด้านล่าง (Bottom Nav)
        if (args.containsKey('mainIndex')) {
          _currentIndex = args['mainIndex'];
        } else if (args.containsKey('initialIndex')) {
          _currentIndex = args['initialIndex']; // เผื่อมีการเรียกใช้แบบเก่า
        }

        // 💡 2. รับค่าแท็บด้านบนของ Your Rent
        if (args.containsKey('tabIndex')) {
          _rentTabIndex = args['tabIndex'];
        }
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 3. เอา const ออก และโยน _rentTabIndex เข้าไปใน RenterYourRentPage
    final List<Widget> pages = [
      const RenterHomePage(),
      RenterYourRentPage(initialIndex: _rentTabIndex), // ส่งค่าแท็บที่ต้องการเปิดไปที่นี่
      const RenterSearchPage(),
      const RenterNotificationsPage(),
      const RenterProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
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