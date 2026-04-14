import 'dart:io';
import 'dart:convert'; // 💡 สำหรับ json.decode
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:http/http.dart' as http; // 💡 สำหรับติดต่อ ImgBB API
import 'owner/check_hand_in.dart'; 
import 'owner/add_vehicle.dart'; 
import 'staff/check_vehicle.dart'; 

class TakePhotoPage extends StatefulWidget {
  final String vehicleName;
  final bool isStaff; 
  final String? ownerId; 
  final String? vehicleId; 
  final List<String>? ownerImages;
  final bool isRenterPickUp; 
  final String? bookingId; 

  const TakePhotoPage({
    super.key, 
    required this.vehicleName, 
    this.isStaff = false, 
    this.ownerId, 
    this.vehicleId, 
    this.ownerImages, 
    this.isRenterPickUp = false,
    this.bookingId,
  });

  @override
  State<TakePhotoPage> createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  final ImagePicker _picker = ImagePicker();
  
  // 💡 ใส่ API Key ของ ImgBB ที่นี่
  final String imgBBKey = '0a99d5ebe05123a47328ece31b15711c'; 

  List<File?> afterImages = [null, null, null, null];
  final List<String> photoLabels = ['Front', 'Back', 'Left', 'Right'];

  Future<void> _pickImage(int index, ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        afterImages[index] = File(photo.path);
      });
    }
  }

  // ==========================================
  // 💡 ฟังก์ชันอัปโหลดรูปภาพไป ImgBB
  // ==========================================
  Future<String?> _uploadImageToImgBB(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgBBKey'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['data']['url']; // 💡 คืนค่า URL ตรงๆ มาเลย
      }
      return null;
    } catch (e) {
      print('ImgBB Upload Error: $e');
      return null;
    }
  }

  // ==========================================
  // 💡 ฟังก์ชันประมวลผลการรับรถ (Renter Pick Up)
  // ==========================================
  Future<void> _processRenterPickUp(List<File> images) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0))),
    );

    try {
      List<String> uploadedUrls = [];
      
      for (int i = 0; i < images.length; i++) {
        String? url = await _uploadImageToImgBB(images[i]);
        if (url != null) {
          uploadedUrls.add(url);
        } else {
          throw Exception("Failed to upload image ${i + 1} to ImgBB");
        }
      }

      // 💡 อัปเดตข้อมูลลง Firestore หลังจากได้ URL ครบแล้ว
      if (widget.bookingId != null) {
        await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update({
          'status': 'using',
          'before_images': uploadedUrls, // เก็บ List ของ URL จาก ImgBB
        });
      }

      if (widget.vehicleId != null) {
        await FirebaseFirestore.instance.collection('vehicles').doc(widget.vehicleId).update({
          'status': 'using', 
        });
      }

      if (context.mounted) {
        Navigator.pop(context); // ปิด Loading
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/renter', 
          arguments: {'mainIndex': 1, 'tabIndex': 1}, 
          (route) => false
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle picked up successfully!', style: TextStyle(fontFamily: 'Poppins')), 
            backgroundColor: Color(0xFF2E7D6E)
          )
        );
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e', style: const TextStyle(fontFamily: 'Poppins')), 
            backgroundColor: Colors.redAccent, 
            duration: const Duration(seconds: 5)
          )
        );
      }
    }
  }

  // --- ส่วนอื่น ๆ ของ UI (GridView, Build Method) คงเดิมตามที่คุณส่งมา ---
  // ... (เพื่อความกระชับ ฉันละส่วน UI ไว้แต่คุณสามารถใช้ UI เดิมได้เลย)
  
  void _goToNextPage() {
    List<File> completedImages = afterImages.whereType<File>().toList();
    if (widget.isRenterPickUp) {
      _processRenterPickUp(completedImages);
      return; 
    }
    
    // Logic การเปลี่ยนหน้าอื่น ๆ (Staff, New Vehicle) ก็ยังคงเหมือนเดิม
    // เพียงแต่ถ้าหน้าเหล่านั้นต้องอัปโหลดรูปด้วย คุณอาจจะต้องปรับให้ใช้ _uploadImageToImgBB เช่นกัน
    _navigateBasedOnContext(completedImages);
  }

  void _navigateBasedOnContext(List<File> completedImages) {
    List<String> allImagePaths = completedImages.map((file) => file.path).toList();
    if (widget.isStaff) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CheckVehiclePage(vehicleId: widget.vehicleId!, vehicleName: widget.vehicleName, ownerId: widget.ownerId!, ownerImages: widget.ownerImages ?? [], staffImages: completedImages)));
    } else if (widget.vehicleName == 'Edit Photos') {
      Navigator.pop(context, allImagePaths);
    } else if (widget.vehicleName == 'New Vehicle') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddVehiclePage(vehicleImagePaths: allImagePaths)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CheckHandInPage(vehicleName: widget.vehicleName, afterImages: completedImages)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ Build Method เดิมของคุณได้เลยครับ
    return _buildMainUI(); 
  }

  Widget _buildMainUI() {
    bool isNewVehicle = widget.vehicleName == 'New Vehicle' || widget.vehicleName == 'Edit Photos';
    List<File> completedImages = afterImages.whereType<File>().toList();
    bool isConfirmEnabled = completedImages.length == 4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)]))),
        title: Text(widget.isRenterPickUp ? 'Pick Up Inspection' : (widget.isStaff ? 'Staff Check Photos' : (isNewVehicle ? 'Add Vehicle Photos' : 'Take Photos')), style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(widget.isRenterPickUp ? 'Verify Vehicle Condition' : widget.vehicleName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showPickerOptions(index),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade400)),
                          child: afterImages[index] != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(afterImages[index]!, fit: BoxFit.cover))
                              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.camera_alt, color: Colors.grey, size: 40), const SizedBox(height: 10), Text(photoLabels[index], style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.grey))]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(42, 35, 66, 1.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: isConfirmEnabled ? _goToNextPage : null,
                child: Text(widget.isRenterPickUp ? 'Confirm Pick Up' : 'Next', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(int index) {
    // ใช้ logic เดิมที่คุณเขียนไว้ได้เลยครับ
    _pickImage(index, ImageSource.camera);
  }
}