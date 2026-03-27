import 'package:flutter/material.dart';
import '../../utils/vehicle_utils.dart'; 

class VehicleCard extends StatelessWidget {
  final String vName;
  final double vRate; // float
  final String imagePath; // สำหรับ Mockup ไปก่อน
  final String vPlate;
  final String vBrand;
  final String vModel;
  final String vType;
  final String vFuel;
  final String vAddress;
  final double vPrice; // float
  final double vDeposit; // float
  final String vStatus;
  final Color statusColor;

  const VehicleCard({
    super.key,
    required this.vName,
    required this.vRate,
    required this.imagePath,
    required this.vPlate,
    required this.vBrand,
    required this.vModel,
    required this.vType,
    required this.vFuel,
    required this.vAddress,
    required this.vPrice,
    required this.vDeposit,
    required this.vStatus,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color.fromRGBO(172, 114, 161, 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // ส่วนหัว
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(42, 35, 66, 1.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      vRate.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ส่วนเนื้อหา
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Plate: $vPlate',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            getFuelIcon(
                              vFuel,
                            ), // ใช้ฟังก์ชันเลือกไอคอนแทน v["typeIcon"]
                            size: 30,
                            color: const Color.fromRGBO(7, 14, 42, 1.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Brand/Model: $vBrand $vModel',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: $vType  |  Fuel: $vFuel',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vAddress,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status Badge
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vStatus,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
