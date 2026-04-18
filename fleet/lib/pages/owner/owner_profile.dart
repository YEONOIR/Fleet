import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 เพิ่ม Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 เพิ่ม Firestore
import '../edit_profile.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  // 💡 ตัวแปรเก็บข้อมูลจาก Firebase
  String _firstName = "Loading...";
  String _lastName = "";
  String _email = "Loading...";
  String _address = "Loading...";
  String _profileImage = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 💡 ฟังก์ชันดึงข้อมูลจาก Database
  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _firstName = userDoc['first_name'] ?? 'Unknown';
            _lastName = userDoc['last_name'] ?? '';
            _email = userDoc['email'] ?? currentUser.email ?? '';
            _address = userDoc['address'] ?? 'No address provided';
            _profileImage = userDoc['profile_image'] ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 💡 ฟังก์ชัน Logout ออกจากระบบ Firebase
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0))) // วงแหวนโหลดตอนดึงข้อมูล
        : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromRGBO(172, 114, 161, 1.0),
                  Color.fromRGBO(7, 14, 42, 1.0),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Text(
                'Your Profile',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // ==========================================
                  // 💡 ส่วนแสดงข้อมูลผู้ใช้ (เชื่อม Firebase แล้ว)
                  // ==========================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          image: DecorationImage(
                            // 💡 เช็คว่ามีรูปใน Database ไหม ถ้าไม่มีใช้ Default
                            image: _profileImage.isNotEmpty
                                ? NetworkImage(_profileImage) as ImageProvider
                                : const AssetImage('assets/icons/avatar.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_firstName $_lastName', // 💡 ชื่อจริง-นามสกุล
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(7, 14, 42, 1.0),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Email : $_email', // 💡 อีเมล
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Address : $_address', // 💡 ที่อยู่
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  _buildProfileMenu(
                    icon: Icons.edit_outlined,
                    title: 'Edit profile',
                    onTap: () async { // 💡 1. ใส่ async
                      // 💡 2. ใช้ await รอรับค่าที่ส่งกลับมาจากหน้า Edit
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );

                      // 💡 3. ถ้าค่าที่ส่งกลับมาเป็น true ให้ทำการดึงข้อมูลใหม่
                      if (result == true) {
                        setState(() {
                          _isLoading = true; // โชว์วงแหวนโหลดแป๊บนึง
                        });
                        _fetchUserData(); // เรียกฟังก์ชันโหลดข้อมูลจาก Firebase ใหม่
                      }
                    },
                  ),

                  // toggle button
                  _buildProfileMenu(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Switch mode',
                    subtitle: 'Change to Renter Profile',
                    trailing: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context, 
                          '/renter',
                          arguments: {'initialIndex': 4},
                        );
                      },
                      child: Container(
                        width: 46,
                        height: 24, 
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(172, 114, 161, 1.0), 
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.centerRight, 
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context, 
                        '/renter',
                        arguments: {'initialIndex': 4},
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Log out
                  _buildProfileMenu(
                    icon: Icons.logout,
                    title: 'Log out',
                    isLogout: true,
                    onTap: _handleLogout, // 💡 เรียกฟังก์ชัน Logout ที่เขียนไว้ด้านบน
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withValues(alpha: 0.1)
                : const Color.fromRGBO(172, 114, 161, 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : const Color.fromRGBO(7, 14, 42, 1.0),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.red : const Color.fromRGBO(7, 14, 42, 1.0),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              )
            : null,
        trailing:
            trailing ??
            (isLogout
                ? null
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  )),
        onTap: onTap,
      ),
    );
  }
}