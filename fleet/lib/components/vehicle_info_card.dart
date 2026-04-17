import 'package:flutter/material.dart';
import '../../utils/vehicle_utils.dart';

class VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const VehicleInfoCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    String imgPath =
        data['imagePath'] ?? data['image'] ?? 'assets/images/car.jpg';
    String vName = data['V Name'] ?? data['name'] ?? 'Unknown Vehicle';
    String vRate = (data['V_Rate'] ?? data['rating'] ?? 0.0).toString();
    String vPlate = data['V Plate'] ?? data['plate'] ?? '-';
    String vModel = data['V Model'] ?? data['model'] ?? '-';
    String vType = data['V Type'] ?? data['vType'] ?? '-';
    String vAddress =
        data['V Address'] ?? data['address'] ?? 'No address provided';
    String vPrice = (data['V Price'] ?? data['price'] ?? 0).toString();
    String vFuel = data['V Fuel'] ?? data['fuel'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromRGBO(172, 114, 161, 0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // ─────────── Header ───────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(42, 35, 66, 1.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        vRate,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─────────── Info ───────────
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imgPath.startsWith('http')
                        ? Image.network(
                            imgPath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.directions_car,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        : Image.asset(
                            imgPath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.directions_car,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                  ),
                  const SizedBox(width: 15),

                  // ─────────── Right Vehicle Info ───────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'License plate: $vPlate',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              getFuelIcon(vFuel),
                              size: 20,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Model: $vModel',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Type: $vType',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vAddress,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Price  ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '$vPrice ฿ / Hr.',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
