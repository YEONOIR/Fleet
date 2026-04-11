import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 เพิ่ม Import Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 เพิ่ม Import Firestore

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // 💡 เพิ่มตัวแปรสำหรับแสดงสถานะโหลด

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 💡 อัปเดตฟังก์ชัน _handleLogin เพื่อเชื่อมต่อ Firebase
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // เริ่มหมุนติ้วๆ
    });

    try {
      // 1. ล็อกอินผ่าน Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2. ไปดึงข้อมูล Role จาก Firestore ตาราง users
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // ดึงค่า role ออกมา (ถ้าไม่มีให้ตั้งค่าเริ่มต้นเป็น 'user')
        String role = userDoc.get('role') ?? 'user';

        if (mounted) {
          // 3. เตะไปยังหน้าต่าง ๆ ตาม Role ที่กำหนดไว้ใน Database
          if (role == 'staff') {
            Navigator.pushReplacementNamed(context, '/staff');
          } else if (role == 'owner') {
            Navigator.pushReplacementNamed(context, '/owner');
          } else {
            // ค่า default คือ user/renter
            Navigator.pushReplacementNamed(context, '/renter');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found in database.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // จัดการ Error กรณีรหัสผิดหรือไม่มีอีเมลในระบบ
      String errorMessage = 'Login failed. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Wrong password provided.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // หยุดโหลด
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.fromRGBO(172, 114, 161, 1.0),
              Color.fromRGBO(251, 217, 250, 1.0),
              Color.fromRGBO(7, 14, 42, 1.0),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 350,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 130),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: 330,
                          padding: const EdgeInsets.only(top: 100, bottom: 40),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(217, 217, 217, 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GradientText(
                                "Login",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 32,
                                  fontFamily: "Poppins",
                                ),
                                colors: const [
                                  Color.fromRGBO(172, 114, 161, 1.0),
                                  Color.fromRGBO(7, 14, 42, 1.0),
                                ],
                                gradientDirection: GradientDirection.btt,
                              ),
                              _loginInput(),
                              const SizedBox(height: 20),
                              _createAccount(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    child: Image(
                      height: 220,
                      width: 220,
                      image: AssetImage("assets/icons/Logo.png"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginInput() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontFamily: "Poppins", fontSize: 14),
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Email',
              labelStyle: TextStyle(fontFamily: "Poppins", fontSize: 14),
              suffixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Password field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontFamily: "Poppins", fontSize: 14),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'Password',
              labelStyle: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.lock_outline_rounded
                      : Icons.lock_open_rounded,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Login button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(172, 114, 161, 1.0),
                    Color.fromRGBO(7, 14, 42, 1.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createAccount() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: const Text(
        'Create an account',
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 13,
          color: Color.fromRGBO(7, 14, 42, 0.8),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}