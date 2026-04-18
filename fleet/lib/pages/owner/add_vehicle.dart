import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../take_photo.dart'; 

class AddVehiclePage extends StatefulWidget {
  final List<String>? vehicleImagePaths;
  const AddVehiclePage({super.key, this.vehicleImagePaths});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedType;
  String? selectedFuel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  List<String>? _currentImagePaths;
  bool _isLoading = false; 

  final List<String> vehicleTypes = [
    'Sedan (4-Door Car)', 'Hatchback (5-Door Car)', 'SUV / PPV (Sport Utility)',
    'MPV (Family Car)', 'Pickup Truck (Open Bed)', 'Van (Passenger Van)',
    'Scooter (Automatic)', 'Motorcycle (Manual Gear)', 'Big Bike (Large Engine)',
    'Campervan (Motorhome)', 'Luxury Car (Premium)', 'Others (Unspecified)',
  ];

  final List<String> fuelTypes = [
    'Gasohol 95 (E10 Blend)', 'Gasohol 91 (E10 Blend)', 'Gasohol E20 (20% Ethanol)',
    'Gasohol E85 (85% Ethanol)', 'Gasoline 95 (Pure Benzine)', 'Diesel (Standard Diesel)',
    'EV (100% Electric)', 'Hybrid / PHEV (Gas & Electric)', 'LPG / CNG (Autogas)',
  ];

  @override
  void initState() {
    super.initState();
    // 💡 แก้ไข: นำรูปที่ได้จากหน้าก่อนหน้าไปเก็บถาวรทันทีก่อนนำมาใช้
    if (widget.vehicleImagePaths != null && widget.vehicleImagePaths!.isNotEmpty) {
      _initPermanentImages(widget.vehicleImagePaths!);
    } else {
      _currentImagePaths = [];
    }
  }

  // 💡 สร้างฟังก์ชันใหม่สำหรับจัดการรูปภาพตอนเริ่มหน้าจอ
  Future<void> _initPermanentImages(List<String> tempPaths) async {
    final permanentPaths = await _saveToPermanentDirectory(tempPaths);
    if (mounted) {
      setState(() {
        _currentImagePaths = permanentPaths;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  // ==========================================
  // 💡 ฟังก์ชัน Helper สำหรับคัดลอกไฟล์จาก Cache ไปโฟลเดอร์ถาวร
  // ==========================================
  Future<List<String>> _saveToPermanentDirectory(List<String> tempPaths) async {
    List<String> permanentPaths = [];
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      for (String path in tempPaths) {
        File tempFile = File(path);
        if (tempFile.existsSync()) {
          // 💡 แก้ไข: เพิ่ม Timestamp นำหน้าชื่อไฟล์ป้องกันการเขียนทับกันเอง
          String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
          String fileName = '${uniqueId}_${p.basename(path)}';
          String newPath = '${appDocDir.path}/$fileName';
          
          File permanentFile = await tempFile.copy(newPath);
          permanentPaths.add(permanentFile.path);
        } else {
          // ถ้าไฟล์ไม่อยู่แล้ว ให้ใช้ path เดิมไปก่อน (จะไปดัก Error ตอน Upload แทน)
          permanentPaths.add(path); 
        }
      }
    } catch (e) {
      print("Error saving images permanently: $e");
      return tempPaths; // ถ้ามี Error ก็คืนค่า path เดิมกลับไป
    }
    return permanentPaths;
  }

  // ==========================================
  // ฟังก์ชัน Helper สำหรับส่ง Notification
  // ==========================================
  Future<void> _sendNotification(String targetUserId, String title, String message, String type, String targetRole) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'user_id': targetUserId, 
        'title': title,
        'message': message,
        'type': type,
        'target_role': targetRole, 
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // ==========================================
  // อัปเดตวิธีอัปโหลดรูปภาพใหม่
  // ==========================================
  Future<String> _uploadImageToImgBB(File imageFile) async {
    const String apiKey = '0a99d5ebe05123a47328ece31b15711c'; 
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    
    try {
      if (!imageFile.existsSync()) {
        throw Exception("The image file was lost from cache. Please select the photos again.");
      }

      final bytes = await imageFile.readAsBytes();

      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'image', 
          bytes,
          filename: imageFile.path.split('/').last.isEmpty ? 'image.jpg' : imageFile.path.split('/').last,
        ));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResult = json.decode(responseData);
        return jsonResult['data']['url'];
      } else {
        throw Exception('Server rejected the upload. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  // ==========================================
  // ฟังก์ชันบันทึกข้อมูลหลัก
  // ==========================================
  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedType == null || selectedFuel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Vehicle Type and Fuel.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }

    if (_currentImagePaths == null || _currentImagePaths!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one vehicle photo.', style: TextStyle(fontFamily: 'Poppins'))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      List<String> imageUrls = [];
      for (String path in _currentImagePaths!) {
        String url = await _uploadImageToImgBB(File(path));
        imageUrls.add(url);
      }

      await FirebaseFirestore.instance.collection('vehicles').add({
        'owner_id': user.uid,
        'vehicle_name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'license_plate': _plateController.text.trim(),
        'vehicle_type': selectedType,
        'fuel': selectedFuel,
        'address': _addressController.text.trim(),
        'price_per_day': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'deposit': double.tryParse(_depositController.text.trim()) ?? 0.0,
        'images': imageUrls,
        'status': 'pending', 
        'pending_type': 'Add',  
        'rating': 0.0,
        'created_at': FieldValue.serverTimestamp(),
      });

      await _sendNotification(
        'staff', 
        'New Vehicle Approval', 
        'A request to add a new ${_brandController.text.trim()} ${_modelController.text.trim()} has been submitted. Please review.', 
        'New Vehicle Request',
        'Staff' 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully! Pending staff approval.', style: TextStyle(fontFamily: 'Poppins')),
            backgroundColor: Color(0xFF2E7D6E),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImageSlider() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.only(top: 15, bottom: 5, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _currentImagePaths!.map((imgPath) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imgPath),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              final newPhotos = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TakePhotoPage(vehicleName: 'Edit Photos')),
              );
              if (newPhotos != null && newPhotos is List<String>) {
                // 💡 นำรูปไปเก็บถาวรก่อนนำมาใช้งาน
                final permanentPhotos = await _saveToPermanentDirectory(newPhotos);
                setState(() => _currentImagePaths = permanentPhotos);
              }
            },
            icon: const Icon(Icons.edit, size: 16, color: Color.fromRGBO(172, 114, 161, 1.0)),
            label: const Text('Edit Photos', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)]),
          ),
        ),
        title: const Text('Add New Vehicle', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (_currentImagePaths != null && _currentImagePaths!.isNotEmpty)
            _buildImageSlider()
          else
            GestureDetector(
              onTap: () async {
                final newPhotos = await Navigator.push(context, MaterialPageRoute(builder: (context) => const TakePhotoPage(vehicleName: 'Add Photos')));
                if (newPhotos != null && newPhotos is List<String>) {
                  // 💡 นำรูปไปเก็บถาวรก่อนนำมาใช้งาน
                  final permanentPhotos = await _saveToPermanentDirectory(newPhotos);
                  setState(() => _currentImagePaths = permanentPhotos);
                }
              },
              child: Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    Text('Tap to add photos', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('General Info', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
                    const SizedBox(height: 15),
                    _buildTextField('Vehicle Name', 'e.g., Sukrit\'s Honda', controller: _nameController),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Brand', 'e.g., Honda', controller: _brandController)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTextField('Model', 'e.g., Civic', controller: _modelController)),
                      ],
                    ),
                    _buildTextField('License Plate', 'e.g., AB 1222', controller: _plateController),
                    const SizedBox(height: 10),

                    const Text('Type & Fuel', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
                    const SizedBox(height: 15),
                    _buildDropdown('Vehicle Type', vehicleTypes, selectedType, (val) => setState(() => selectedType = val)),
                    _buildDropdown('Fuel/Energy', fuelTypes, selectedFuel, (val) => setState(() => selectedFuel = val)),
                    const SizedBox(height: 10),

                    const Text('Location & Pricing', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
                    const SizedBox(height: 15),
                    _buildTextField('Pickup Address', 'Enter full address...', maxLines: 3, controller: _addressController),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Price / Hour (฿)', '0.00', isNumber: true, controller: _priceController)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTextField('Deposit (฿)', '0.00', isNumber: true, controller: _depositController)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(172, 114, 161, 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _isLoading ? null : _submitVehicle,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Add Vehicle', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isNumber = false, int maxLines = 1, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller, 
            maxLines: maxLines,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0), width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter $label';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: selectedValue,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0), width: 1.5)),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontFamily: 'Poppins')));
            }).toList(),
            onChanged: onChanged,
            hint: const Text('Select', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}