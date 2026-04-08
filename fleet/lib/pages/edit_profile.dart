import 'dart:io'; // 💡 นำเข้าสำหรับใช้ File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 💡 นำเข้าสำหรับ ImagePicker

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // 💡 สร้าง Controller สำหรับจัดการข้อมูลในช่องกรอก
  final TextEditingController _nameController = TextEditingController(text: 'Sukrit Chatchawal');
  final TextEditingController _emailController = TextEditingController(text: 'firstsukit189@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: '081-234-5678');
  final TextEditingController _dobController = TextEditingController(text: '18/09/2002'); 
  final TextEditingController _addressController = TextEditingController(
      text: '111/11, Ander Road, Cromium, Roselina, Bangkok 11111');

  // ==========================================
  // 💡 ตัวแปรและฟังก์ชันสำหรับเลือกรูปโปรไฟล์
  // ==========================================
  final ImagePicker _picker = ImagePicker();
  File? _profileImage; // ตัวแปรเก็บรูปที่เลือกใหม่

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        _profileImage = File(photo.path); // อัปเดตรูปใหม่ลงในตัวแปร
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
                _pickImage(ImageSource.camera); // เปิดกล้อง
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color.fromRGBO(172, 114, 161, 1.0)),
              title: const Text('Choose from Gallery', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery); // เปิดอัลบั้ม
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

  // ฟังก์ชันเปิดปฏิทินเลือกวันเกิด
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002, 9, 18), 
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

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2E7D6E), 
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
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
              colors: [
                Color.fromRGBO(172, 114, 161, 1.0),
                Color.fromRGBO(7, 14, 42, 1.0)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // ==========================================
            // 1. ส่วนของรูปโปรไฟล์ (Avatar)
            // ==========================================
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
                      // 💡 เช็คว่ามีการเลือกรูปใหม่หรือยัง ถ้ามีให้ใช้ FileImage ถ้าไม่มีให้ใช้ AssetImage เดิม
                      image: DecorationImage(
                        image: _profileImage != null 
                            ? FileImage(_profileImage!) as ImageProvider
                            : const AssetImage('assets/icons/avatar.jpg'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showPickerOptions, // 💡 ผูกฟังก์ชันโชว์ Modal เลือกรูปตรงนี้
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(7, 14, 42, 1.0), 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ==========================================
            // 2. ส่วนของฟอร์มกรอกข้อมูล
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    label: 'Date of Birth',
                    controller: _dobController,
                    icon: Icons.calendar_month_outlined,
                    readOnly: true, 
                    onTap: () => _selectDate(context), 
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: 'Address',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                    maxLines: 3, 
                  ),
                  const SizedBox(height: 40),

                  // ==========================================
                  // 3. ปุ่ม Save Changes
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(172, 114, 161, 1.0), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _saveProfile,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  // ==========================================
  // Helper Widget สำหรับสร้างช่องกรอกข้อมูล
  // ==========================================
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
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(7, 14, 42, 1.0),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly, 
          onTap: onTap,       
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 
              ? Icon(icon, color: Colors.grey, size: 22) 
              : Padding(
                  padding: const EdgeInsets.only(bottom: 45),
                  child: Icon(icon, color: Colors.grey, size: 22),
                ),
            filled: true,
            fillColor: Colors.grey.shade100, 
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0), width: 2), 
            ),
          ),
        ),
      ],
    );
  }
}