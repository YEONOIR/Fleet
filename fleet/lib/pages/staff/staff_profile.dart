import 'package:flutter/material.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ส่วนหัว (Header)
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
                'Staff Profile',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ส่วนเนื้อหา
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // ข้อมูลส่วนตัว Staff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // จัดให้อยู่กึ่งกลางแนวตั้งพอดีกับรูป
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5), width: 2), // เพิ่มกรอบให้ดูมีความเป็น Admin
                          image: const DecorationImage(
                            image: AssetImage('assets/icons/avatar.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sukrit Chatchawal',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(7, 14, 42, 1.0),
                              ),
                            ),
                            SizedBox(height: 4),
                            // ป้ายบอกตำแหน่ง Admin สีเด่นๆ
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(172, 114, 161, 1.0),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email : firstsukit189@gmail.com',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50), // ดันปุ่ม Logout ลงไปข้างล่างนิดนึง

                  // ปุ่ม Log out (เหลือแค่อันเดียวตามที่คุณขอ)
                  _buildProfileMenu(
                    icon: Icons.logout,
                    title: 'Log out',
                    isLogout: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully', style: TextStyle(fontFamily: 'Poppins'))),
                      );

                      // กลับไปหน้าแรกสุด
                      Navigator.pushNamedAndRemoveUntil(
                        context, 
                        '/', 
                        (route) => false, 
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Component สำหรับสร้างปุ่มเมนู
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
            color: Colors.grey.withOpacity(0.08),
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
                ? Colors.red.withOpacity(0.1)
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
        trailing: trailing ??
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