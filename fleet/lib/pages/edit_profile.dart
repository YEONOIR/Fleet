import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 💡 นำเข้า Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 นำเข้า Firestore
import 'package:firebase_storage/firebase_storage.dart'; // 💡 นำเข้า Storage สำหรับอัปโหลดรูป

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); 
  final TextEditingController _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage; // เก็บรูปที่เลือกใหม่จากเครื่อง
  String? _existingImageUrl; // เก็บ URL รูปเดิมที่ดึงมาจาก Database
  
  bool _isLoading = true; // สำหรับตอนดึงข้อมูลครั้งแรก
  bool _isSaving = false; // สำหรับตอนกดปุ่ม Save

  @override
  void initState() {
    super.initState();
    _loadUserData(); // โหลดข้อมูลเมื่อเปิดหน้า
  }

  // ==========================================
  // 💡 1. ฟังก์ชันดึงข้อมูลผู้ใช้ปัจจุบันมาแสดง
  // ==========================================
  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          setState(() {
            // นำ First Name และ Last Name มาต่อกันเพื่อแสดงในช่องเดียว
            _nameController.text = "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
            _emailController.text = data['email'] ?? user.email ?? '';
            _phoneController.text = data['phone'] ?? '';
            _addressController.text = data['address'] ?? '';
            _existingImageUrl = data['profile_image'] ?? '';
            
            // แปลง Timestamp วันเกิดกลับเป็น String
            if (data['dob'] != null) {
              DateTime dobDate = (data['dob'] as Timestamp).toDate();
              _dobController.text = "${dobDate.day.toString().padLeft(2, '0')}/${dobDate.month.toString().padLeft(2, '0')}/${dobDate.year}";
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 💡 2. ฟังก์ชันอัปเดตข้อมูลลง Firebase
  // ==========================================
  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String imageUrl = _existingImageUrl ?? '';

      // ถ้ายูสเซอร์เลือกรูปใหม่ ให้ทำการอัปโหลดขึ้น Firebase Storage ก่อน
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
        await storageRef.putFile(_profileImage!);
        imageUrl = await storageRef.getDownloadURL(); // เอา URL ที่ได้มาเก็บไว้
      }

      // แยก Full Name กลับเป็น First Name และ Last Name ก่อนเซฟ
      List<String> names = _nameController.text.trim().split(' ');
      String firstName = names.isNotEmpty ? names[0] : '';
      String lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      // แปลง String วันเกิดกลับเป็น DateTime เพื่อสร้าง Timestamp
      Timestamp? dobTimestamp;
      if (_dobController.text.isNotEmpty) {
        List<String> parts = _dobController.text.split('/');
        if (parts.length == 3) {
          DateTime parsedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          dobTimestamp = Timestamp.fromDate(parsedDate);
        }
      }

      // อัปเดตข้อมูลกลับลง Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'first_name': firstName,
        'last_name': lastName,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        if (dobTimestamp != null) 'dob': dobTimestamp,
        'profile_image': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!', style: TextStyle(fontFamily: 'Poppins')),
            backgroundColor: Color(0xFF2E7D6E), 
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // กลับไปหน้า Profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        _profileImage = File(photo.path);
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color.fromRGBO(7, 14, 42, 1.0)),
              title: const Text('Take Photo', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color.fromRGBO(172, 114, 161, 1.0)),
              title: const Text('Choose from Gallery', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose(); 
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1), 
      firstDate: DateTime(1900), 
      lastDate: DateTime.now(), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(172, 114, 161, 1.0), 
              onPrimary: Colors.white, 
              onSurface: Color.fromRGBO(7, 14, 42, 1.0), 
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromRGBO(172, 114, 161, 1.0), 
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        _dobController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0)))
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5), width: 3),
                      // 💡 โลจิกเช็ครูปภาพใหม่
                      image: DecorationImage(
                        image: _profileImage != null 
                            ? FileImage(_profileImage!) as ImageProvider
                            : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                                ? NetworkImage(_existingImageUrl!)
                                : const AssetImage('assets/icons/avatar.jpg'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showPickerOptions, 
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(7, 14, 42, 1.0), 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTextField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
                  const SizedBox(height: 20),
                  // 💡 ทำให้ Email ไม่สามารถแก้ไขได้โดยตรง (Read Only) เพราะผูกกับ Auth Login
                  _buildTextField(label: 'Email Address', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, readOnly: true),
                  const SizedBox(height: 20),
                  _buildTextField(label: 'Phone Number', controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildTextField(label: 'Date of Birth', controller: _dobController, icon: Icons.calendar_month_outlined, readOnly: true, onTap: () => _selectDate(context)),
                  const SizedBox(height: 20),
                  _buildTextField(label: 'Address', controller: _addressController, icon: Icons.location_on_outlined, maxLines: 3),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(172, 114, 161, 1.0), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                      ),
                      onPressed: _isSaving ? null : _saveProfile, // ปิดปุ่มตอนกำลังเซฟ
                      child: _isSaving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color.fromRGBO(7, 14, 42, 1.0))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly, 
          onTap: onTap,       
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 
              ? Icon(icon, color: Colors.grey, size: 22) 
              : Padding(padding: const EdgeInsets.only(bottom: 45), child: Icon(icon, color: Colors.grey, size: 22)),
            filled: true,
            fillColor: Colors.grey.shade100, 
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0), width: 2)),
          ),
        ),
      ],
    );
  }
}