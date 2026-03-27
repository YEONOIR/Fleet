import 'package:flutter/material.dart';
import 'staff_home.dart'; // หน้าแสดงรายการคำขอ
import 'staff_notifications.dart'; // หน้าแจ้งเตือนที่คุณทำไว้
import 'staff_profile.dart'; // หรือหน้าโปรไฟล์ที่คุณมี
import '../../components/staff_nav_bar.dart';

class StaffMainPage extends StatefulWidget {
  const StaffMainPage({super.key});

  @override
  State<StaffMainPage> createState() => _StaffMainPageState();
}

class _StaffMainPageState extends State<StaffMainPage> {
  int _currentIndex = 0;

  // รายการหน้าที่จะสลับไปมา
  final List<Widget> _pages = [
    const StaffHomePage(),
    const StaffNotificationsPage(),
    const StaffProfilePage(), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 💡 สำคัญ: ถ้าอยากให้รอยเว้าสวย ต้อง extendBody
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