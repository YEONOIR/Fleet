import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/renter/renter_profile.dart';
import 'pages/renter/renter_main.dart';
import 'pages/owner/owner_main.dart';
import 'pages/owner/owner_profile.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/renter': (context) => const RenterMainPage(),
        '/owner': (context) => const OwnerMainPage(), 
        '/renter_profile' : (context) => const RenterProfilePage(),
        '/owner_profile' : (context) => const OwnerProfilePage()
      },
    );
  }
}