import 'package:flutter/material.dart';
import '../edit_profile.dart';

class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          image: const DecorationImage(
                            image: AssetImage('assets/icons/avatar.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sukrit Chatchawal',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(7, 14, 42, 1.0),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Email : firstsukit189@gmail.com',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Address : 111/11, Ander Road,\nCromium, Roselina, Bangkok 11111',
                              style: TextStyle(
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

                  // 💡 2. อัปเดตปุ่ม Edit Profile ของ Owner
                  _buildProfileMenu(
                    icon: Icons.edit_outlined,
                    title: 'Edit profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(), // 💡 พาไปหน้า EditProfilePage
                        ),
                      );
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
                        padding: const EdgeInsets.all(2), 
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
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out successfully')),
                      );

                      Navigator.pushNamedAndRemoveUntil(
                        context, 
                        '/', 
                        (route) => false, 
                      );
                    },
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