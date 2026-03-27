import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'owner/check_hand_in.dart'; // เตรียมส่งไปหน้าตรวจสภาพ
import 'owner/add_vehicle.dart'; // 💡 นำเข้าหน้า Add Vehicle

class TakePhotoPage extends StatefulWidget {
  final String vehicleName;
  const TakePhotoPage({super.key, required this.vehicleName});

  @override
  State<TakePhotoPage> createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  final ImagePicker _picker = ImagePicker();
  
  // เก็บรูปทั้ง 4 มุม (หน้า, หลัง, ซ้าย, ขวา)
  List<File?> afterImages = [null, null, null, null];
  final List<String> photoLabels = ['Front', 'Back', 'Left', 'Right'];

  // 💡 1. ฟังก์ชันดึงรูป (รับพารามิเตอร์ว่าจะเอากล้องหรือแกลเลอรี่)
  Future<void> _pickImage(int index, ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        afterImages[index] = File(photo.path);
      });
    }
  }

  // 💡 2. ฟังก์ชันเด้ง Bottom Sheet ให้เลือกว่าจะถ่ายหรือเลือกจาก Gallery
  void _showPickerOptions(int index) {
    bool isNewVehicle = widget.vehicleName == 'New Vehicle' || widget.vehicleName == 'Edit Photos';
    
    // ถ้าเป็นการเพิ่มรถใหม่ ให้มีสิทธิ์เลือกจากแกลเลอรี่ได้
    if (isNewVehicle) {
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
                  _pickImage(index, ImageSource.camera); // เปิดกล้อง
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color.fromRGBO(172, 114, 161, 1.0)),
                title: const Text('Choose from Gallery', style: TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, ImageSource.gallery); // เปิดอัลบั้ม
                },
              ),
            ],
          ),
        ),
      );
    } else {
      // แต่ถ้าเป็นการรับรถคืน บังคับให้ใช้กล้องถ่ายสดๆ เท่านั้น
      _pickImage(index, ImageSource.camera);
    }
  }

  // กดปุ่ม Next เพื่อไปหน้าถัดไป (แยกเงื่อนไข)
  void _goToNextPage() {
    if (afterImages.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take all 4 pictures of the vehicle.', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.orange),
      );
      return;
    }

    List<File> completedImages = afterImages.whereType<File>().toList();
    List<String> allImagePaths = completedImages.map((file) => file.path).toList();

    // 💡 โหมดแก้ไขรูปภาพ (ส่งรูปกลับไปหน้าเดิม)
    if (widget.vehicleName == 'Edit Photos') {
      Navigator.pop(context, allImagePaths); 
    } 
    // 💡 โหมดเพิ่มรถใหม่ (เปิดหน้า Add Vehicle)
    else if (widget.vehicleName == 'New Vehicle') {
      Navigator.pushReplacement( 
        context,
        MaterialPageRoute(
          builder: (context) => AddVehiclePage(vehicleImagePaths: allImagePaths),
        ),
      );
    } 
    // 💡 โหมดคืนรถ (ไปหน้า Check Hand In)
    else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckHandInPage(vehicleName: widget.vehicleName, afterImages: completedImages),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNewVehicle = widget.vehicleName == 'New Vehicle' || widget.vehicleName == 'Edit Photos';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
        title: Text(
          isNewVehicle ? 'Add Vehicle Photos' : 'Take Photos', 
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isNewVehicle ? 'Upload Vehicle Angles' : widget.vehicleName, 
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isNewVehicle 
                      ? 'Please take or upload 4 photos of the vehicle for the listing.'
                      : 'Please take 4 photos to verify the current condition of the vehicle.', 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)
                  ),
                  const SizedBox(height: 30),

                  // สร้าง Grid 2x2 สำหรับถ่ายรูป 4 มุม
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.85, 
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showPickerOptions(index), // 💡 3. เรียกใช้ฟังก์ชันเลือกรูปตรงนี้
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid), 
                          ),
                          child: afterImages[index] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(afterImages[index]!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                                    const SizedBox(height: 10),
                                    Text(photoLabels[index], style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.grey)),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // ปุ่ม Next
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(42, 35, 66, 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _goToNextPage, 
                child: Text(
                  isNewVehicle ? 'Next to Add Details' : 'Next to Inspection', 
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}