import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/renter/renter_profile.dart';
import 'pages/renter/renter_main.dart';
import 'pages/renter/renter_topup.dart';
import 'pages/owner/owner_main.dart';
import 'pages/owner/owner_profile.dart';
import 'pages/staff/staff_main.dart';
import 'firebase_options.dart';

void main() async {
  // ต้องมีบรรทัดนี้เพื่อให้ Flutter เตรียมความพร้อมก่อนรัน Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // โหลดการตั้งค่า Firebase ที่เราทำไว้ในขั้นตอนที่ 2
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet',
      // ลบ home: const TempRoleSelector(), ออกไปเลย เพื่อป้องกันการทำงานซ้ำซ้อน
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // บอกให้แอปเริ่มต้นที่ Route '/'
      routes: {
        // เปิดใช้งาน Route '/' ให้ชี้ไปที่หน้า LoginPage
        '/': (context) => const LoginPage(),
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