import 'package:flutter/material.dart';

class RenterInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final double rating;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String renterImage;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(42, 35, 66, 0.05), // สีม่วงอ่อนโปร่งแสง
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
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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