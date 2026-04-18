import 'dart:io'; // 💡 นำเข้า dart:io เพื่อใช้โหลดรูปจาก Path ในเครื่อง
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../components/tenant_card.dart';
import '../review_page.dart'; 
import '../../utils/vehicle_utils.dart'; 
import '../take_photo.dart';

class ScheduleDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const ScheduleDetailPage({super.key, required this.booking});

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic> _vehicleData = {};
  Map<String, dynamic> _bookingData = {};

  @override
  void initState() {
    super.initState();
    _fetchRealData();
  }

  // ==========================================
  // 💡 ฟังก์ชันดึงข้อมูลรถและการจองจาก Firestore
  // ==========================================
  Future<void> _fetchRealData() async {
    try {
      String bId = widget.booking['bookingId'] ?? widget.booking['id'] ?? '';
      String vId = widget.booking['vehicleId'] ?? 
                   widget.booking['vehicle_id'] ?? 
                   (widget.booking['vehicleData'] != null ? widget.booking['vehicleData']['id'] : '');

      if (bId.isNotEmpty && vId.isNotEmpty) {
        var bDoc = await FirebaseFirestore.instance.collection('bookings').doc(bId).get();
        var vDoc = await FirebaseFirestore.instance.collection('vehicles').doc(vId).get();

        if (bDoc.exists && vDoc.exists && mounted) {
          setState(() {
            _bookingData = bDoc.data() as Map<String, dynamic>;
            _bookingData['id'] = bDoc.id; 
            
            _vehicleData = vDoc.data() as Map<String, dynamic>;
            _vehicleData['id'] = vDoc.id;
          });
        }
      }
    } catch (e) {
      print("Error fetching detail: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accept': 
      case 'accepted': return const Color(0xFF2E8B57); 
      case 'complete': 
      case 'completed': return const Color(0xFF28A4C9); 
      case 'cancel': 
      case 'cancelled': 
      case 'reject': return const Color(0xFFA52A2A); 
      case 'pending': return Colors.orange; 
      case 'using': return const Color.fromRGBO(172, 114, 161, 1.0); 
      default: return Colors.black;
    }
  }

  Widget _buildImageGallery() {
    List<dynamic> images = _vehicleData['images'] ?? [];
    if (images.isEmpty) images = ['assets/images/car.jpg'];

    return Container(
      height: 200, 
      color: Colors.grey.shade200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(15),
        itemCount: images.length, 
        itemBuilder: (context, index) {
          String imgPath = images[index].toString();
          return Container(
            width: 250, 
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.hardEdge,
            child: imgPath.startsWith('http')
                ? Image.network(imgPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[400], child: const Icon(Icons.broken_image)))
                : Image.asset(imgPath, fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context, Color statusColor, String status) {
    String vFuel = _vehicleData['fuel'] ?? '-';
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoColumn('License Plate', _vehicleData['license_plate'] ?? '-'),
                    const SizedBox(height: 20),
                    _buildInfoColumn('Brand', _vehicleData['brand'] ?? '-'),
                    const SizedBox(height: 20),
                    _buildInfoColumn('Model', _vehicleData['model'] ?? '-'),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(getFuelIcon(vFuel), size: 45, color: const Color.fromRGBO(7, 14, 42, 1.0)),
                    const SizedBox(height: 5),
                    Text(vFuel.toUpperCase() == 'EV' ? 'ENERGY' : vFuel.toUpperCase(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 15),
                    _buildStatusBadge(status.toUpperCase(), statusColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoColumn('Vehicle Type', _vehicleData['vehicle_type'] ?? '-'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rating', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FleetEntityReviewPage(
                          isCar: true, 
                          entityName: 'Vehicle Reviews', 
                          targetId: _vehicleData['id'] ?? '' 
                        ))),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text((_vehicleData['rating'] ?? 0.0).toStringAsFixed(1), style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15), 
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FleetEntityReviewPage(
                          isCar: false, 
                          entityName: 'User Reviews', 
                          targetId: _bookingData['renter_id'] ?? widget.booking['renterId'] ?? '' 
                        ))),
                        child: const Text('Comment', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, decoration: TextDecoration.underline, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(_vehicleData['address'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Deposit (฿)', (_bookingData['deposit_paid'] ?? 0).toString()),
              _buildInfoColumn('Price/Hour (฿)', (_vehicleData['price_per_day'] ?? 0).toString()), 
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Colors.white),
          const SizedBox(width: 8),
          Text(status, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Widget สำหรับแสดงรูประหว่างเช่า (อัปเดตให้รองรับ Local File Path)
  // ==========================================
  Widget _buildRentImages(List<dynamic> images, String emptyText) {
    if (images.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(emptyText, style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
      );
    }

    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          String imgPath = images[index].toString().trim(); // 💡 ตัดช่องว่างทิ้งเผื่อ error
          
          Widget imageWidget;
          if (imgPath.startsWith('http')) {
            imageWidget = Image.network(imgPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)));
          } else if (imgPath.startsWith('/')) { // 💡 รองรับกรณีที่ข้อมูลเป็น Local File Path (เช่น /data/user/...)
            imageWidget = Image.file(File(imgPath), fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)));
          } else {
            imageWidget = Image.asset(imgPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)));
          }

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.hardEdge,
            child: imageWidget,
          );
        },
      ),
    );
  }

  Widget _buildBeforeRentImages() {
    List<dynamic> images = [];
    if (_bookingData['before_images'] != null && (_bookingData['before_images'] as List).isNotEmpty) {
      images = _bookingData['before_images'];
    } else if (_bookingData['beforeImages'] != null && (_bookingData['beforeImages'] as List).isNotEmpty) {
      images = _bookingData['beforeImages'];
    } else if (_bookingData['photos_before'] != null && (_bookingData['photos_before'] as List).isNotEmpty) {
      images = _bookingData['photos_before'];
    } else if (widget.booking['beforeRentImages'] != null && (widget.booking['beforeRentImages'] as List).isNotEmpty) {
      images = widget.booking['beforeRentImages'];
    }
    return _buildRentImages(images, 'No before-rent images available.');
  }

  Widget _buildAfterRentImages() {
    List<dynamic> images = [];
    // 💡 ค้นหาทุก Key ที่เป็นไปได้
    if (_bookingData['after_images'] != null && (_bookingData['after_images'] as List).isNotEmpty) {
      images = _bookingData['after_images'];
    } else if (_bookingData['afterImages'] != null && (_bookingData['afterImages'] as List).isNotEmpty) {
      images = _bookingData['afterImages'];
    } else if (_bookingData['return_images'] != null && (_bookingData['return_images'] as List).isNotEmpty) {
      images = _bookingData['return_images'];
    } else if (_bookingData['handin_images'] != null && (_bookingData['handin_images'] as List).isNotEmpty) {
      images = _bookingData['handin_images'];
    } else if (_bookingData['photos_after'] != null && (_bookingData['photos_after'] as List).isNotEmpty) {
      images = _bookingData['photos_after'];
    } else if (widget.booking['afterRentImages'] != null && (widget.booking['afterRentImages'] as List).isNotEmpty) {
      images = widget.booking['afterRentImages'];
    }
    return _buildRentImages(images, 'No after-rent images available.');
  }

  Widget _buildDynamicBottomSection(BuildContext context, String status) {
    double totalPrice = (_bookingData['total_price'] ?? 0).toDouble();
    String pendingType = _bookingData['pending_type'] ?? widget.booking['pendingType'] ?? 'rent'; 

    switch (status.toLowerCase()) {
      case 'pending':
        if (pendingType == 'return') {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pictures before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
                _buildBeforeRentImages(),
                const SizedBox(height: 20),

                const Text('The renter has returned the vehicle. Please inspect it.', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(172, 114, 161, 1.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final String finalBookingId = (_bookingData['id'] ?? '').toString().trim().isNotEmpty
                          ? _bookingData['id'].toString().trim()
                          : (widget.booking['bookingId'] ?? widget.booking['id'] ?? '').toString().trim();

                      final String finalVehicleId = (_vehicleData['id'] ?? '').toString().trim().isNotEmpty
                          ? _vehicleData['id'].toString().trim()
                          : (widget.booking['vehicleId'] ?? widget.booking['vehicle_id'] ??
                            (widget.booking['vehicleData'] != null ? widget.booking['vehicleData']['id'] : '')).toString().trim();

                      if (finalBookingId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: Booking ID is missing!'), backgroundColor: Colors.redAccent),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakePhotoPage(
                            vehicleName: _vehicleData['vehicle_name'] ?? _vehicleData['brand'] ?? 'Check Return',
                            bookingId: finalBookingId,
                            vehicleId: finalVehicleId,
                            isStaff: false, 
                          ),
                        ),
                      );
                    },
                    child: const Text('Inspect Returned Vehicle', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Review this rental request.', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.redAccent, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showRejectReasonModal(context),
                        child: const Text('Decline', style: TextStyle(fontFamily: 'Poppins', color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFF2E8B57),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showAcceptModal(context),
                        child: const Text('Accept', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      case 'complete':
      case 'completed':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price paid', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('฿ $totalPrice', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              
              const Text('Pictures before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
              _buildBeforeRentImages(),
              const SizedBox(height: 20),

              const Text('Pictures upon return', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
              _buildAfterRentImages(), // 💡 เรียกใช้ฟังก์ชันที่อัปเดตแล้ว
              const SizedBox(height: 20),

              const Text('Defect', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(_bookingData['handin_defect'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );

      case 'using':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Rental Fee', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('฿ $totalPrice', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Pictures before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
              _buildBeforeRentImages(),
            ],
          ),
        );

      case 'cancel':
      case 'reject':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reason for cancellation', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(_bookingData['reject_reason'] ?? _bookingData['cancel_reason'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );

      case 'accept':
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Rental Fee', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
              Text('฿ $totalPrice', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0))),
      );
    }

    String status = _bookingData['status'] ?? widget.booking['status'] ?? 'Pending';
    Color statusColor = _getStatusColor(status);
    String titleName = _vehicleData['vehicle_name'] ?? _vehicleData['brand'] ?? 'Vehicle Detail';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(titleName, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            _buildVehicleInfo(context, statusColor, status), 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TenantCard(booking: widget.booking), 
            ),
            _buildDynamicBottomSection(context, status),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 💡 Modal Functions 
  // ==========================================
  void _showRejectReasonModal(BuildContext pageContext) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Decline Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please state the reason for declining this request:', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
            const SizedBox(height: 15),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g., The car is currently unavailable...',
                hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0)), borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF07B75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(dialogContext); 
              _showConfirmRejectModal(pageContext, reasonController.text, widget.booking['renterName'] ?? 'the renter');
            },
            child: const Text('Next', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showConfirmRejectModal(BuildContext pageContext, String reason, String renterName) {
    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (confirmDialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Rejection', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Text('Are you sure you want to decline $renterName\'s request?\n\nYour Reason:\n"$reason"', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(confirmDialogContext), child: const Text('Back', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(42, 35, 66, 1.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              showDialog(
                context: confirmDialogContext, 
                barrierDismissible: false, 
                builder: (loadingContext) => const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0)))
              );

              try {
                String bId = _bookingData['id'] ?? widget.booking['id'] ?? widget.booking['bookingId'] ?? '';
                String rId = _bookingData['renter_id'] ?? widget.booking['renterId'] ?? '';
                
                if (bId.isEmpty) throw Exception("Booking ID is missing.");

                double refundAmount = (_bookingData['deposit_paid'] ?? 0).toDouble() + (_bookingData['total_price'] ?? 0).toDouble();

                await FirebaseFirestore.instance.collection('bookings').doc(bId).update({
                  'status': 'cancel', 
                  'cancel_reason': reason, 
                });

                await FirebaseFirestore.instance.collection('users').doc(rId).update({
                  'wallet_balance': FieldValue.increment(refundAmount),
                });

                await FirebaseFirestore.instance.collection('transactions').add({
                  'user_id': rId,
                  'type': 'refund',
                  'amount': refundAmount,
                  'timestamp': FieldValue.serverTimestamp(),
                  'status': 'success',
                  'description': 'Refund for cancelled booking (Owner declined)',
                });

                await FirebaseFirestore.instance.collection('notifications').add({
                  'user_id': rId,
                  'target_role': 'Renter',
                  'type': 'cancel',
                  'title': 'Booking Declined by Owner',
                  'message': 'Your rental request was declined. Reason: $reason. A full refund of ฿$refundAmount has been issued to your wallet.',
                  'is_read': false,
                  'created_at': FieldValue.serverTimestamp(),
                });

                if (pageContext.mounted) {
                  Navigator.pop(confirmDialogContext); 
                  Navigator.pop(pageContext); 
                  Navigator.pop(pageContext); 
                  ScaffoldMessenger.of(pageContext).showSnackBar(const SnackBar(content: Text('Rejection sent and refund processed.', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.redAccent));
                }
              } catch (e) {
                if (confirmDialogContext.mounted) Navigator.pop(confirmDialogContext); 
                if (pageContext.mounted) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Send to Renter', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAcceptModal(BuildContext pageContext) {
    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (acceptDialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Accept Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Text('Do you confirm to rent to ${widget.booking['renterName'] ?? 'the renter'}?', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(acceptDialogContext), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF75DB73), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              showDialog(
                context: acceptDialogContext, 
                barrierDismissible: false, 
                builder: (loadingContext) => const Center(child: CircularProgressIndicator())
              );

              try {
                String bId = _bookingData['id'] ?? widget.booking['id'] ?? widget.booking['bookingId'] ?? '';
                String rId = _bookingData['renter_id'] ?? widget.booking['renterId'] ?? '';
                
                if (bId.isEmpty) throw Exception("Booking ID is missing.");

                await FirebaseFirestore.instance.collection('bookings').doc(bId).update({
                  'status': 'accept',
                });

                await FirebaseFirestore.instance.collection('notifications').add({
                  'user_id': rId,
                  'target_role': 'Renter',
                  'type': 'rent accepted',
                  'title': 'Request Accepted!',
                  'message': 'Your rental request for ${_vehicleData['vehicle_name'] ?? 'the vehicle'} has been accepted by the owner.',
                  'is_read': false,
                  'created_at': FieldValue.serverTimestamp(),
                });

                if (pageContext.mounted) {
                  Navigator.pop(acceptDialogContext); 
                  Navigator.pop(pageContext); 
                  Navigator.pop(pageContext); 
                  ScaffoldMessenger.of(pageContext).showSnackBar(const SnackBar(content: Text('Rental accepted successfully!', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Color(0xFF2E8B57)));
                }
              } catch (e) {
                if (acceptDialogContext.mounted) Navigator.pop(acceptDialogContext); 
                if (pageContext.mounted) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Confirm Rent', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}