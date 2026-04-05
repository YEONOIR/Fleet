import 'package:flutter/material.dart';
// อย่าลืม import ไฟล์ vehicle_info_card.dart ให้ตรงกับ path ของโปรเจคด้วยนะครับ
import '../../components/vehicle_info_card.dart'; 
import 'vehicle_rent_detail.dart';

class RenterHomePage extends StatelessWidget {
  const RenterHomePage({super.key});

  // Mock data for top 5 cars (อัปเดตให้ตรงกับที่ VehicleInfoCard ต้องการ)
  static const List<Map<String, dynamic>> _topCars = [
    {
      'name': "Sukrit's Honda",
      'rating': '4.5',
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'vType': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg', // สามารถแก้ path รูปให้ตรงกับที่มีในโฟลเดอร์ assets ได้เลย
    },
    {
      'name': "Pimthida's Bike",
      'rating': '4.5',
      'plate': 'BB 567',
      'model': 'GRAND FILANO HYBRID',
      'vType': 'Motorcycle',
      'address': '222 JJ Village, Loo Road, Llama, Penguin, Bangkok 22222',
      'price': 80,
      'image': 'assets/images/bike.jpg',
    },
    {
      'name': "Aran's Toyota",
      'rating': '4.3',
      'plate': 'CC 8901',
      'model': 'Camry 2.5 HEV',
      'vType': '4 Door Car',
      'address': '333 Siam Square, Pathum Wan, Bangkok 10330',
      'price': 300,
      'image': 'assets/images/car2.jpg',
    },
    {
      'name': "Nari's Mazda",
      'rating': '4.0',
      'plate': 'DD 2345',
      'model': 'Mazda 3 Hatchback',
      'vType': 'Hatchback',
      'address': '444 Sukhumvit Rd, Khlong Toei, Bangkok 10110',
      'price': 220,
      'image': 'assets/images/car3.jpg',
    },
    {
      'name': "Krit's BMW",
      'rating': '4.8',
      'plate': 'EE 6789',
      'model': 'X3 xDrive30e',
      'vType': 'SUV',
      'address': '555 Silom Rd, Bang Rak, Bangkok 10500',
      'price': 450,
      'image': 'assets/images/car4.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Header ──
            _buildHeader(context),
            const SizedBox(height: 20),

            // ── Credit & Top Up Row ──
            _buildCreditTopUpRow(context),
            const SizedBox(height: 24),

            // ── Map Section ──
            _buildMapSection(),
            const SizedBox(height: 24),

            // ── Top 5 Cars Title ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Top 5 most car near you',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF070E2A),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Car Cards ──
            ...List.generate(_topCars.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCarCard(context, _topCars[index]),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────── Welcome Header ───────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFAC72A1),
            Color(0xFF070E2A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Column(
        children: [
          Text(
            'Welcome, Sukrit',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Credit & Top Up Row ───────────
  Widget _buildCreditTopUpRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Credit pill
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFCE93D8),
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card, size: 20, color: Color(0xFF070E2A)),
                  SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        'Credit',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF070E2A),
                        ),
                      ),
                      Text(
                        '100',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF070E2A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Top Up pill
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/renter/topup');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFCE93D8),
                    width: 1.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 20, color: Color(0xFF070E2A)),
                    SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          'Top up',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF070E2A),
                          ),
                        ),
                        Icon(Icons.add, size: 18, color: Color(0xFF070E2A)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Map Placeholder Section ───────────
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Vehicles near you',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF070E2A),
            ),
          ),
          const SizedBox(height: 10),
          // Map placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFE8E4E8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Grid lines to simulate map
                  CustomPaint(
                    size: const Size(double.infinity, 180),
                    painter: _MapGridPainter(),
                  ),
                  // Location pin
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.navigation,
                          color: Color(0xFF070E2A),
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your Location',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF070E2A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Car marker top-right
                  Positioned(
                    top: 30,
                    right: 50,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  // Bike marker left
                  Positioned(
                    top: 60,
                    left: 40,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF9C27B0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.two_wheeler,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  // Another car marker
                  Positioned(
                    bottom: 40,
                    right: 80,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Build Car Card ───────────
  Widget _buildCarCard(BuildContext context, Map<String, dynamic> car) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleRentDetailPage(vehicleData: car),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: VehicleInfoCard(
          data: car,
        ),
      ),
    );
  }
}

// ─────────── Map Grid Painter ───────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0C8D0)
      ..strokeWidth = 0.6;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Road-like thicker lines
    final roadPaint = Paint()
      ..color = const Color(0xFFBDB5BD)
      ..strokeWidth = 3.0;

    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), roadPaint);

    // Block fills to simulate buildings
    final blockPaint = Paint()..color = const Color(0xFFD8D0D8);
    canvas.drawRect(Rect.fromLTWH(10, 10, 50, 40), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, 10, 60, 50), blockPaint);
    canvas.drawRect(Rect.fromLTWH(10, size.height * 0.5, 70, 30), blockPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.75, size.height * 0.45, 50, 40), blockPaint);

    // Green park area
    final parkPaint = Paint()..color = const Color(0xFFB8D8B8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, size.height * 0.55, 40, 35),
        const Radius.circular(6),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}