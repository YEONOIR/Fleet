import 'package:flutter/material.dart';
// import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/renter/renter_profile.dart';
import 'pages/renter/renter_main.dart';
import 'pages/renter/renter_topup.dart';
import 'pages/owner/owner_main.dart';
import 'pages/owner/owner_profile.dart';
import 'pages/staff/staff_main.dart';
import 'mockup/temp_role_selector.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet',
      home: const TempRoleSelector(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // hide this for mock up test
        // '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/renter': (context) => const RenterMainPage(),
        '/renter/topup': (context) => const RenterTopUpPage(),
        '/owner': (context) => const OwnerMainPage(), 
        '/renter_profile' : (context) => const RenterProfilePage(),
        '/owner_profile' : (context) => const OwnerProfilePage(),
        '/staff': (context) => const StaffMainPage(),
      },
    );
  }
}