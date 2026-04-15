import 'package:flutter/material.dart';
import '../pages/review_page.dart';

class RenterInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final double rating;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String renterImage;
  final String renterId;

  const RenterInfoCard({
    super.key,
    required this.name,
    required this.phone,
    required this.rating,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.renterImage,
    required this.renterId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, // 💡 1. เปลี่ยนพื้นหลังเป็นสีขาวตรงนี้
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(renterImage),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(7, 14, 42, 1.0),
                      ),
                    ),
                    Text(
                      'Tel: $phone',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => FleetEntityReviewPage( // 💡 เอา const ออก
                      isCar: false, 
                      entityName: 'User Reviews',
                      targetId: renterId, // 💡 ส่งค่า targetId ไป
                    )
                  ));
                },
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    // 💡 2. เปลี่ยนสี Check Reviews เป็นสีม่วงตรงนี้
                    const Text('Check Reviews >', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Color.fromRGBO(172, 114, 161, 1.0))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(startDate, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(endDate, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(startTime, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(endTime, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}