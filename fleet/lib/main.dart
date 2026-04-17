import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/renter/renter_profile.dart';
import 'pages/renter/renter_main.dart';
import 'pages/renter/renter_topup.dart';
import 'pages/owner/owner_main.dart';
import 'pages/owner/owner_profile.dart';
import 'pages/staff/staff_main.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/renter': (context) => const RenterMainPage(),
        '/renter/topup': (context) => const RenterTopUpPage(),
        '/owner': (context) => const OwnerMainPage(),
        '/renter_profile': (context) => const RenterProfilePage(),
        '/owner_profile': (context) => const OwnerProfilePage(),
        '/staff': (context) => const StaffMainPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFAC72A1)),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const RoleRouter();
        }

        return const LoginPage();
      },
    );
  }
}

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
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          String role = doc['role'] ?? 'renter';

          if (mounted) {
            if (role == 'owner') {
              Navigator.pushReplacementNamed(context, '/owner');
            } else if (role == 'staff') {
              Navigator.pushReplacementNamed(context, '/staff');
            } else {
              Navigator.pushReplacementNamed(context, '/renter');
            }
          }
        } else {
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
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFAC72A1)),
            SizedBox(height: 16),
            Text(
              'Setting up your workspace...',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
