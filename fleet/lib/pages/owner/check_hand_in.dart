import 'dart:io';
import 'dart:convert'; // 💡 สำหรับ json.decode
import 'package:http/http.dart' as http; // 💡 สำหรับติดต่อ ImgBB API
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../rating.dart';

class CheckHandInPage extends StatefulWidget {
  final String vehicleName;
  final List<File> afterImages;
  final String bookingId;

  const CheckHandInPage({
    super.key,
    required this.vehicleName,
    required this.afterImages,
    required this.bookingId,
  });

  @override
  State<CheckHandInPage> createState() => _CheckHandInPageState();
}

class _CheckHandInPageState extends State<CheckHandInPage> {
  bool hasDefect = false;
  TextEditingController defectController = TextEditingController();

  // 💡 เก็บ URL รูปก่อนเช่าที่ดึงมาจาก Firestore
  List<String> beforeImages = [];
  bool isLoadingBeforeImages = true;
  String? _fetchError;

  // 💡 ใส่ API Key ของ ImgBB
  final String imgBBKey = '0a99d5ebe05123a47328ece31b15711c'; 

  @override
  void initState() {
    super.initState();
    _fetchBeforeImages();
  }

  @override
  void dispose() {
    defectController.dispose();
    super.dispose();
  }

  // ==========================================
  // 💡 ฟังก์ชันอัปโหลดรูปภาพไป ImgBB (สำหรับ After Rent)
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
        return jsonResponse['data']['url']; 
      }
      return null;
    } catch (e) {
      debugPrint('ImgBB Upload Error: $e');
      return null;
    }
  }

  // ==========================================
  // 💡 ดึง URL รูปก่อนเช่าจาก Firestore
  // ==========================================
  Future<void> _fetchBeforeImages() async {
    final String bId = widget.bookingId.trim();
    if (bId.isEmpty) {
      debugPrint('❌ CheckHandIn: bookingId ว่างเปล่า ไม่สามารถดึงรูปได้');
      if (mounted) {
        setState(() {
          _fetchError = 'Booking ID is missing.';
          isLoadingBeforeImages = false;
        });
      }
      return;
    }

    try {
      debugPrint('🔍 CheckHandIn: กำลังดึงรูปจาก bookings/$bId');

      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bId)
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('❌ CheckHandIn: ไม่พบเอกสาร bookings/$bId');
        if (mounted) {
          setState(() {
            _fetchError = 'Booking not found (ID: $bId)';
            isLoadingBeforeImages = false;
          });
        }
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      List<dynamic> rawImages = [];

      if (data['before_images'] != null && (data['before_images'] as List).isNotEmpty) {
        rawImages = data['before_images'] as List;
      } else if (data['beforeImages'] != null && (data['beforeImages'] as List).isNotEmpty) {
        rawImages = data['beforeImages'] as List;
      } else if (data['photos_before'] != null && (data['photos_before'] as List).isNotEmpty) {
        rawImages = data['photos_before'] as List;
      }

      final List<String> validUrls = rawImages
          .map((e) => e.toString().trim())
          .where((url) => url.isNotEmpty && url.startsWith('http'))
          .toList();

      if (mounted) {
        setState(() {
          beforeImages = validUrls;
          isLoadingBeforeImages = false;
          if (rawImages.isNotEmpty && validUrls.isEmpty) {
            _fetchError = 'Images found but URLs are invalid.\nRaw: ${rawImages.first}';
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ CheckHandIn: Error fetching before images: $e');
      if (mounted) {
        setState(() {
          _fetchError = 'Failed to load images: $e';
          isLoadingBeforeImages = false;
        });
      }
    }
  }

  Widget _buildBeforeRentImages() {
    if (isLoadingBeforeImages) {
      return Container(
        width: double.infinity,
        height: 130,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0)),
              SizedBox(height: 8),
              Text('Loading before rent images...', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_fetchError != null && beforeImages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.orange.shade50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
            const SizedBox(height: 8),
            Text(_fetchError!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.orange)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  isLoadingBeforeImages = true;
                  _fetchError = null;
                  beforeImages = [];
                });
                _fetchBeforeImages();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            ),
          ],
        ),
      );
    }

    if (beforeImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: 130,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 32, color: Colors.grey),
              SizedBox(height: 8),
              Text('No before rent images found.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: beforeImages.map((imgUrl) {
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imgUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color.fromRGBO(172, 114, 161, 1.0)),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade300,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.grey, size: 28),
                          SizedBox(height: 4),
                          Text('Load failed', style: TextStyle(fontSize: 9, color: Colors.grey, fontFamily: 'Poppins')),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAfterRentImages() {
    if (widget.afterImages.isEmpty) {
      return Container(
        width: double.infinity,
        height: 130,
        color: Colors.grey[200],
        child: const Center(
          child: Text('No after rent images.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.afterImages.map((imageFile) {
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(imageFile, width: 100, height: 100, fit: BoxFit.cover),
              ),
            );
          }).toList(),
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
        title: const Text(
          'Check hand in',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _buildBeforeRentImages(),

                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('After rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _buildAfterRentImages(),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Inspection', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          title: const Text('Report Defect / Damage', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          subtitle: const Text('Check this if the vehicle has new damages.', style: TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                          value: hasDefect,
                          activeColor: Colors.redAccent,
                          onChanged: (bool? value) => setState(() => hasDefect = value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (hasDefect) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: defectController,
                            maxLines: 4,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Describe the defect (e.g., Scratch on front bumper)...',
                              hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75DB73),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _handleConfirm,
                child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirm() async {
    if (hasDefect && defectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please provide details of the defects.', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0))));

    try {
      var bDoc = await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
      if (!mounted) return;
      Navigator.pop(context); // ปิด Loading

      if (!bDoc.exists || bDoc.data() == null) throw Exception("Booking not found");

      var bData = bDoc.data() as Map<String, dynamic>;
      double maxDeposit = (bData['deposit_paid'] ?? 0).toDouble();

      if (hasDefect) {
        _showDeductModal(maxDeposit, bData);
      } else {
        _finishHandIn(0.0, bData);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showDeductModal(double maxDeposit, Map<String, dynamic> bData) {
    TextEditingController deductController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deduct Deposit', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter the amount to deduct from the renter's deposit.\n(Maximum: ฿$maxDeposit)", style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            const SizedBox(height: 15),
            TextField(
              controller: deductController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: '฿',
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              double deductAmount = double.tryParse(deductController.text.trim()) ?? 0.0;
              
              if (deductAmount > maxDeposit) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Cannot deduct more than the deposit limit (฿$maxDeposit)', style: const TextStyle(fontFamily: 'Poppins')),
                  backgroundColor: Colors.redAccent,
                ));
                return;
              }

              Navigator.pop(context);
              _finishHandIn(deductAmount, bData);
            },
            child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _finishHandIn(double deductAmount, Map<String, dynamic> bData) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0))));

    try {
      // 💡 1. อัปโหลดรูปภาพ After Images ไปยัง ImgBB
      List<String> afterImageUrls = [];
      for (int i = 0; i < widget.afterImages.length; i++) {
        String? url = await _uploadImageToImgBB(widget.afterImages[i]);
        if (url != null) {
          afterImageUrls.add(url);
        } else {
          throw Exception("Failed to upload image ${i + 1} to ImgBB");
        }
      }

      double deposit = (bData['deposit_paid'] ?? 0).toDouble();
      double price = (bData['total_price'] ?? 0).toDouble();
      String rId = bData['renter_id'] ?? '';
      String oId = bData['owner_id'] ?? '';
      String vId = bData['vehicle_id'] ?? '';

      double renterRefund = deposit - deductAmount;
      double ownerEarning = price + deductAmount;

      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Update Booking Status & After Images 💡
      var bRef = FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId);
      batch.update(bRef, {
        'status': 'complete',
        'handin_defect': hasDefect ? defectController.text.trim() : '',
        'deducted_deposit': deductAmount,
        'refunded_deposit': renterRefund,
        'after_images': afterImageUrls, // 💡 บันทึก URL รูปภาพตอนคืนรถ
        'completed_at': FieldValue.serverTimestamp(),
      });

      // 2. Update Vehicle Status
      if (vId.isNotEmpty) {
        var vRef = FirebaseFirestore.instance.collection('vehicles').doc(vId);
        batch.update(vRef, {'status': 'available'});
      }

      // 3. Update Renter Wallet & Create Transaction
      if (rId.isNotEmpty) {
        var rRef = FirebaseFirestore.instance.collection('users').doc(rId);
        batch.update(rRef, {'wallet_balance': FieldValue.increment(renterRefund)});
        
        var rTxRef = FirebaseFirestore.instance.collection('transactions').doc();
        batch.set(rTxRef, {
          'user_id': rId,
          'type': 'refund',
          'amount': renterRefund,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'success',
          'description': 'Deposit refund (Deducted: ฿$deductAmount)',
        });

        // แจ้งเตือนผู้เช่า
        var notifRenterRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notifRenterRef, {
          'user_id': rId,
          'target_role': 'Renter',
          'type': 'return success',
          'title': 'Vehicle Returned Successfully',
          'message': 'Your rental is complete. You received a deposit refund of ฿$renterRefund. Tap here to rate the vehicle.',
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
          'action_type': 'rate_vehicle', 
          'booking_id': widget.bookingId,
          'vehicle_id': vId,
          'vehicle_name': widget.vehicleName, 
        });
      }

      // 4. Update Owner Wallet & Create Transaction
      if (oId.isNotEmpty) {
        var oRef = FirebaseFirestore.instance.collection('users').doc(oId);
        batch.update(oRef, {'wallet_balance': FieldValue.increment(ownerEarning)});
        
        var oTxRef = FirebaseFirestore.instance.collection('transactions').doc();
        batch.set(oTxRef, {
          'user_id': oId,
          'type': 'income',
          'amount': ownerEarning,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'success',
          'description': 'Rental income + Deducted deposit',
        });

        // แจ้งเตือนผู้ให้เช่า
        var notifOwnerRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notifOwnerRef, {
          'user_id': oId,
          'target_role': 'Owner',
          'type': 'return success',
          'title': 'Return Confirmed',
          'message': 'Vehicle return completed. Earning of ฿$ownerEarning has been added to your wallet.',
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      Navigator.pop(context); // ปิด Loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle returned successfully!'), backgroundColor: Colors.green),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RatingPage(
              isRatingRenter: true,
              targetId: rId,
              bookingId: widget.bookingId,
              targetName: bData['renterName'] ?? 'the renter',
              targetImage: bData['renterImage'],
            )));
      });

    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}