import 'package:flutter/material.dart';
import 'vehicle_mini_card.dart';
import '../pages/take_photo.dart';
import '../pages/owner/schedule_detail.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isRent = request['Request Type'] == 'Rent';
    final startDateParts = request['Rent_Start'].toString().split(' ');
    final endDateParts = request['Rent Handin'].toString().split(' ');

    String rImage = request['renterImage'] ?? 'assets/icons/avatar.jpg';
    ImageProvider avatarImage = rImage.startsWith('http')
        ? NetworkImage(rImage)
        : AssetImage(rImage) as ImageProvider;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5)),
      ),
      child: Column(
        children: [
          // ─────────── Header ───────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(42, 35, 66, 1.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: avatarImage,
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request['Acc FName']} ${request['Acc LName']}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tel: ${request['Acc Phone']}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      request['Acc Rate'].toStringAsFixed(1),
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

          // ─────────── Info ───────────
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRent ? 'Request to rent' : 'Request to hand in',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        Text(
                          '${startDateParts[0]}    ${startDateParts.length > 1 ? startDateParts[1] : ''}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${endDateParts[0]}    ${endDateParts.length > 1 ? endDateParts[1] : ''}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),

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

                // ─────────── Action Button ───────────
                isRent
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleDetailPage(
                                booking: {
                                  'bookingId': request['bookingId'],
                                  'vehicleId': request['vehicleData']['id'],
                                  'renterId': request['renterId'],
                                  'renterName':
                                      '${request['Acc FName']} ${request['Acc LName']}',
                                  'tel': request['Acc Phone'],
                                  'rating': request['Acc Rate'].toString(),
                                  'startDate': startDateParts[0],
                                  'endDate': endDateParts[0],
                                  'startTime': startDateParts.length > 1
                                      ? startDateParts[1]
                                      : '',
                                  'endTime': endDateParts.length > 1
                                      ? endDateParts[1]
                                      : '',
                                  'status': request['Rent Status'],
                                  'remark': request['remark'] ?? '-',
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D354),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Manage Request',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          final String bookingId = (request['bookingId'] ?? '')
                              .toString()
                              .trim();
                          final String vehicleId =
                              (request['vehicleData']['id'] ?? '')
                                  .toString()
                                  .trim();
                          final String vehicleName =
                              (request['vehicleData']['V Name'] ?? 'Vehicle')
                                  .toString();

                          if (bookingId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error: Booking ID is missing!',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakePhotoPage(
                                vehicleName: vehicleName,
                                vehicleId: vehicleId,
                                bookingId: bookingId,
                              ),
                            ),
                          );
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

  Widget _buildStatusBadge(String text, bool isRent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRent ? const Color(0xFFD39A3D) : const Color(0xFF6B66CA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6B66CA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'Accept Hand in',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
