import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pages/owner/check_hand_in.dart'; // เตรียมส่งไปหน้าตรวจสภาพ

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

  // ฟังก์ชันเปิดกล้อง
  Future<void> _takePhoto(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        afterImages[index] = File(photo.path);
      });
    }
  }

  // กดปุ่ม Next เพื่อไปหน้า Inspection
  void _goToInspection() {
    // ดักจับว่าถ่ายรูปครบ 4 รูปหรือยัง
    if (afterImages.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take all 4 pictures of the vehicle.', style: TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // แปลง List<File?> เป็น List<File> เพราะเราชัวร์แล้วว่ามันไม่ null
    List<File> completedImages = afterImages.whereType<File>().toList();

    // ส่งรูปที่ถ่ายเสร็จแล้ว ไปยังหน้า CheckHandInPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckHandInPage(
          vehicleName: widget.vehicleName,
          afterImages: completedImages, // 💡 ส่งรูปไปที่นี่!
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Take Photos', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
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
                  Text(widget.vehicleName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Please take 4 photos to verify the current condition of the vehicle.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 30),

                  // สร้าง Grid 2x2 สำหรับถ่ายรูป 4 มุม
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.85, // ปรับสัดส่วนกล่องให้สวย
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _takePhoto(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            // 💡 แก้ตรงนี้: เปลี่ยนเป็นเส้นทึบ (solid) แทน
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
                  backgroundColor: const Color.fromRGBO(42, 35, 66, 1.0), // ใช้สีม่วงเข้มสำหรับหน้าถ่ายรูป
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _goToInspection,
                child: const Text('Next to Inspection', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}