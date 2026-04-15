import 'package:flutter/material.dart';
import 'mock_auth.dart'; // 💡 import ไฟล์ mock_auth

class TempRoleSelector extends StatelessWidget {
  const TempRoleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(7, 14, 42, 1.0), // พื้นหลังสีกรมท่าของแอป
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.car_rental, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Dev Mode 🛠️',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                'Select role to test UI',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 50),

              // 1. ปุ่มเข้าโหมด User (Owner / Renter)
              GestureDetector(
                onTap: () {
                  MockAuth.setRole('User'); // 💡 เซ็ตค่าตัวแปรจำลอง
                  // 💡 วิ่งไปหน้าของ User (ใส่หน้า Home ของ User ที่นี่)
                  Navigator.pushReplacementNamed(context, '/renter');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged in as User')));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(172, 114, 161, 1.0), // สีม่วง
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text('Login as User', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // 2. ปุ่มเข้าโหมด Staff
              GestureDetector(
                onTap: () {
                  MockAuth.setRole('Staff'); // 💡 เซ็ตค่าตัวแปรจำลอง
                  // 💡 วิ่งไปหน้าของ Staff (ใส่หน้า Staff ของคุณที่นี่)
                                    Navigator.pushReplacementNamed(context, '/staff');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged in as Staff')));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A4C9), // สีฟ้า
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text('Login as Staff', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}