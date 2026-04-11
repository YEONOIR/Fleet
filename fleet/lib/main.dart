import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 นำเข้า Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 นำเข้า Firestore

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
  WidgetsFlutterBinding.ensureInitialized();
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
      debugShowCheckedModeBanner: false,
      // 💡 เปลี่ยนมาใช้ home แทน initialRoute เพื่อให้หน้าแรกคือ "ด่านตรวจ"
      home: const AuthGate(), 
      routes: {
        '/login': (context) => const LoginPage(), // 💡 เปลี่ยนชื่อ Route ของหน้า Login นิดหน่อย
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

// ==========================================
// 💡 ด่านตรวจเช็คสถานะการล็อกอิน (Auth Gate)
// ==========================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // เช็คสถานะแบบ Real-time ว่ามีคนล็อกอินอยู่ไหม
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ถ้ากำลังโหลดข้อมูล
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1))),
          );
        }

        // ถ้ามี User ล็อกอินค้างอยู่ 
        if (snapshot.hasData && snapshot.data != null) {
          return const RoleRouter(); // 💡 ส่งไปให้ฟังก์ชัน RoleRouter ตรวจสอบสิทธิ์ (Renter/Owner/Staff)
        }

        // ถ้าไม่มีใครล็อกอิน ให้ไปที่หน้า Login
        return const LoginPage();
      },
    );
  }
}

// ==========================================
// 💡 ฟังก์ชันเช็คสิทธิ์ (Role) แล้วโยนไปหน้า Main ที่ถูกต้อง
// ==========================================
class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // ดึงข้อมูล User จาก Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          String role = doc['role'] ?? 'renter'; // ค่าเริ่มต้นคือ renter
          
          if (mounted) {
            // โยนไปหน้าต่างๆ ตาม Role ที่เจอ
            if (role == 'owner') {
              Navigator.pushReplacementNamed(context, '/owner');
            } else if (role == 'staff') {
              Navigator.pushReplacementNamed(context, '/staff');
            } else {
              Navigator.pushReplacementNamed(context, '/renter');
            }
          }
        } else {
          // ถ้าไม่มีข้อมูลใน Firestore (อาจจะโดนลบ) ให้เตะออกจากระบบ
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } catch (e) {
        print("Error checking role: $e");
        await FirebaseAuth.instance.signOut();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // หน้าจอโหลดชั่วคราวระหว่างรอเช็ค Role 
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFAC72A1)),
            SizedBox(height: 16),
            Text('Setting up your workspace...', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}