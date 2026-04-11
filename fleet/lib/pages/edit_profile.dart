import 'dart:io';
import 'dart:convert'; // 💡 เพิ่มสำหรับแปลงข้อมูล JSON
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // 💡 เพิ่มสำหรับส่งรูปไป ImgBB

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(); 
  final TextEditingController _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _existingImageUrl;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          setState(() {
            _firstNameController.text = data['first_name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            _emailController.text = data['email'] ?? user.email ?? '';
            _phoneController.text = data['phone'] ?? '';
            _addressController.text = data['address'] ?? '';
            _existingImageUrl = data['profile_image'] ?? '';
            
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
  // 💡 ฟังก์ชันใหม่! อัปโหลดรูปลง ImgBB แทน Firebase
  // ==========================================
  Future<String> _uploadImageToImgBB(File imageFile) async {
    // ⚠️ เอา API Key จากเว็บ ImgBB มาใส่ในเครื่องหมายคำพูดด้านล่างนี้เลยครับ
    const String apiKey = '0a99d5ebe05123a47328ece31b15711c'; 
    
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResult = json.decode(responseData);
      // คืนค่า String URL ของรูปภาพกลับไป
      return jsonResult['data']['url'];
    } else {
      throw Exception('Failed to upload image to ImgBB');
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String imageUrl = _existingImageUrl ?? '';

      // 💡 ถ้ายูสเซอร์เลือกรูปใหม่ ให้เรียกใช้ฟังก์ชัน ImgBB
      if (_profileImage != null) {
        imageUrl = await _uploadImageToImgBB(_profileImage!);
      }

      Timestamp? dobTimestamp;
      if (_dobController.text.isNotEmpty) {
        List<String> parts = _dobController.text.split('/');
        if (parts.length == 3) {
          DateTime parsedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          dobTimestamp = Timestamp.fromDate(parsedDate);
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
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
        Navigator.pop(context, true); // รีเฟรชหน้าโปรไฟล์
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
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'First Name', 
                          controller: _firstNameController, 
                          icon: Icons.person_outline
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Last Name', 
                          controller: _lastNameController, 
                          icon: Icons.person_outline
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                      onPressed: _isSaving ? null : _saveProfile,
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