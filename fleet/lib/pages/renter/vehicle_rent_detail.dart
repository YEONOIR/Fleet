import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/search_calendar.dart';
import '../../components/time_selector.dart';
import '../../utils/vehicle_utils.dart';
import 'rent_payment.dart';
import '../review_page.dart';
import '../../components/rent_booking_modal.dart';

class VehicleRentDetailPage extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleRentDetailPage({super.key, required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    List<dynamic> galleryImages =
        (vehicleData['images'] != null &&
            (vehicleData['images'] as List).isNotEmpty)
        ? vehicleData['images']
        : [vehicleData['imagePath'] ?? 'assets/images/car.jpg'];

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(172, 114, 161, 1.0),
                Color.fromRGBO(7, 14, 42, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          vehicleData['V Name'] ?? 'Vehicle Detail',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(15),
                      itemCount: galleryImages.length,
                      itemBuilder: (context, index) {
                        String imgPath = galleryImages[index].toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imgPath.startsWith('http')
                                ? Image.network(
                                    imgPath,
                                    fit: BoxFit.cover,
                                    width: 250,
                                    errorBuilder: (ctx, err, stack) =>
                                        Container(
                                          width: 250,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  )
                                : Image.asset(
                                    imgPath,
                                    fit: BoxFit.cover,
                                    width: 250,
                                    errorBuilder: (ctx, err, stack) =>
                                        Container(
                                          width: 250,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.directions_car,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
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
                                  _buildInfoColumn(
                                    'License Plate',
                                    vehicleData['V Plate'] ?? '-',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn(
                                    'Brand',
                                    vehicleData['V Brand'] ?? '-',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn(
                                    'Model',
                                    vehicleData['V Model'] ?? '-',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    getFuelIcon(vehicleData['V Fuel'] ?? ''),
                                    size: 45,
                                    color: const Color.fromRGBO(7, 14, 42, 1.0),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    vehicleData['V Fuel']
                                                ?.toString()
                                                .toUpperCase() ==
                                            'EV'
                                        ? 'ENERGY'
                                        : (vehicleData['V Fuel'] ?? 'FUEL')
                                              .toString()
                                              .toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildStatusBadge(
                                    'Available',
                                    const Color(0xFF6DDA75),
                                  ),
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
                            _buildInfoColumn(
                              'Vehicle Type',
                              vehicleData['V Type'] ?? '-',
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rating',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      vehicleData['V_Rate']?.toString() ??
                                          '0.0',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FleetEntityReviewPage(
                                                  isCar: true,
                                                  entityName: 'Vehicle Reviews',
                                                  targetId:
                                                      vehicleData['id'] ??
                                                      vehicleData['vehicle_id'] ??
                                                      '',
                                                ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Comment',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                          color: Color.fromRGBO(
                                            172,
                                            114,
                                            161,
                                            1.0,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                            const Text(
                              'Address',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                vehicleData['V Address'] ?? '-',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn(
                              'Deposit (฿)',
                              vehicleData['V Deposit']?.toString() ?? '0',
                            ),
                            _buildInfoColumn(
                              'Price/Hour (฿)',
                              vehicleData['V Price']?.toString() ?? '-',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A65C8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  _showRentCalendarModal(context);
                },
                child: const Text(
                  'Rent',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Colors.white),
          const SizedBox(width: 8),
          Text(
            status,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showRentCalendarModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return RentBookingModal(vehicleData: vehicleData);
      },
    );
  }
}
