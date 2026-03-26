import 'package:flutter/material.dart';
import 'vehicle_mini_card.dart'; // ดึง Mini Card มาใช้
import '../pages/take_photo.dart'; // ดึงหน้ากล้องมาใช้
import '../pages/owner/schedule_detail.dart';

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
                    ? GestureDetector( // 💡 กรณี Rent: ปุ่มเหลือง ไปหน้า Detail
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleDetailPage(booking: {
                                'renterName': '${request['Acc FName']} ${request['Acc LName']}',
                                'tel': request['Acc Phone'],
                                'rating': request['Acc Rate'].toString(),
                                'startDate': startDateParts[0],
                                'endDate': endDateParts[0],
                                'startTime': startDateParts.length > 1 ? startDateParts[1] : '',
                                'endTime': endDateParts.length > 1 ? endDateParts[1] : '',
                                'status': request['Rent Status'],
                                'remark': request['remark'] ?? '-',
                              }),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D354), // สีเหลือง
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('Manage Request', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      )
                    : GestureDetector( // 💡 กรณี Hand in: ปุ่มม่วง ไปหน้ากล้อง
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
  Widget _buildAcceptButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF6B66CA), borderRadius: BorderRadius.circular(10)),
      child: const Center(child: Text('Accept Hand in', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
    );
  }
}