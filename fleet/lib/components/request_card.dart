import 'package:flutter/material.dart';
import 'vehicle_mini_card.dart'; // ดึง Mini Card มาใช้
import 'take_photo.dart'; // ดึงหน้ากล้องมาใช้

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isRent = request['Request Type'] == 'Rent';
    final startDateParts = request['Rent_Start'].toString().split(' ');
    final endDateParts = request['Rent Handin'].toString().split(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5)),
      ),
      child: Column(
        children: [
          // ----------------------------------------
          // 1. Header (ชื่อผู้เช่า + เรตติ้ง)
          // ----------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(42, 35, 66, 1.0),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: AssetImage(request['renterImage'])),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${request['Acc FName']} ${request['Acc LName']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Tel: ${request['Acc Phone']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                    const SizedBox(width: 4),
                    Text(request['Acc Rate'].toStringAsFixed(1), style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          
          // ----------------------------------------
          // 2. เนื้อหา (เวลา + ข้อมูลรถ + ปุ่มกด)
          // ----------------------------------------
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isRent ? 'Request to rent' : 'Request to hand in', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
                    _buildStatusBadge(isRent ? 'Rent' : 'Hand in', isRent),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${startDateParts[0]}    ${startDateParts.length > 1 ? startDateParts[1] : ''}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                        Text('${endDateParts[0]}    ${endDateParts.length > 1 ? endDateParts[1] : ''}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Vehicle Mini Card
                VehicleMiniCard(
                  vName: request['vehicleData']['V Name'],
                  vRate: request['vehicleData']['V_Rate'],
                  imagePath: request['vehicleData']['imagePath'],
                  vPlate: request['vehicleData']['V Plate'],
                  vBrand: request['vehicleData']['V Brand'],
                  vModel: request['vehicleData']['V Model'],
                  vType: request['vehicleData']['V Type'],
                  vFuel: request['vehicleData']['V Fuel'],
                  vAddress: request['vehicleData']['V Address'],
                  vPrice: request['vehicleData']['V Price'],
                ),
                const SizedBox(height: 15),
                
                // ปุ่ม Action
                isRent
                    ? Row(
                        children: [
                          Expanded(child: _buildActionButton(Icons.close, const Color(0xFFF07B75), () => _showRejectReasonModal(context))),
                          const SizedBox(width: 15),
                          Expanded(child: _buildActionButton(Icons.check, const Color(0xFF75DB73), () => _showAcceptModal(context))),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TakePhotoPage(vehicleName: request['vehicleData']['V Name'])));
                        },
                        child: _buildAcceptButton(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Helper Widgets & Modals (ย้ายมาอยู่ในนี้ทั้งหมด)
  // ==========================================
  Widget _buildStatusBadge(String text, bool isRent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isRent ? const Color(0xFFD39A3D) : const Color(0xFF6B66CA), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black87, size: 28),
      ),
    );
  }

  Widget _buildAcceptButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFF6B66CA), borderRadius: BorderRadius.circular(10)),
      child: const Center(child: Text('Accept', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
    );
  }

  void _showRejectReasonModal(BuildContext context) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF07B75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              _showConfirmRejectModal(context, reasonController.text);
            },
            child: const Text('Next', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showConfirmRejectModal(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Rejection', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Text('Are you sure you want to decline ${request['Acc FName']}\'s request?\n\nYour Reason:\n"$reason"', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(42, 35, 66, 1.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejection sent to the renter.', style: TextStyle(fontFamily: 'Poppins'))));
            },
            child: const Text('Send to Renter', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAcceptModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Accept Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Text('Do you confirm to rent "${request['vehicleData']['V Name']}" to ${request['Acc FName']}?', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF75DB73), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rental accepted successfully!', style: TextStyle(fontFamily: 'Poppins'))));
            },
            child: const Text('Confirm Rent', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}