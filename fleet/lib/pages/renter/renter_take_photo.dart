import 'package:flutter/material.dart';

class RenterTakePhotoPage extends StatefulWidget {
  const RenterTakePhotoPage({super.key});

  @override
  State<RenterTakePhotoPage> createState() => _RenterTakePhotoPageState();
}

class _RenterTakePhotoPageState extends State<RenterTakePhotoPage> {
  int currentStep = 1;

  void _takePicture() {
    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
    } else {
      // ครบ 4 รูปแล้ว กดยืนยันให้ส่งค่า true กลับไป
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Camera', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Capture 4 Pictures',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // กล่องจำลองกล้อง
            Container(
              width: 300,
              height: 300,
              color: Colors.grey.shade300,
            ),
            
            const SizedBox(height: 20),
            
            // ตัวนับ
            Container(
              width: 300,
              alignment: Alignment.centerLeft,
              child: Text(
                '$currentStep/4',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // ปุ่มถ่ายรูป / ปุ่มเสร็จสิ้น
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: currentStep == 4 ? const Color(0xFF75DB73) : const Color.fromRGBO(7, 14, 42, 1.0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentStep == 4 ? Icons.check : Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}