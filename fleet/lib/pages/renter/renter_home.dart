import 'package:flutter/material.dart';
import 'renter_car_detail.dart';

class RenterHomePage extends StatelessWidget {
  const RenterHomePage({super.key});

  // Mock data for top 5 cars
  static const List<Map<String, dynamic>> _topCars = [
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'icon': Icons.directions_car,
      'color': Color(0xFF1A1A2E),
    },
    {
      'name': "Pimthida's Bike",
      'rating': 4.5,
      'plate': 'BB 567',
      'model': 'GRAND FILANO HYBRID',
      'type': 'Motorcycle',
      'address': '222 JJ Village, Loo Road, Llama, Penguin, Bangkok 22222',
      'price': 80,
      'icon': Icons.two_wheeler,
      'color': Color(0xFF4A1942),
    },
    {
      'name': "Aran's Toyota",
      'rating': 4.3,
      'plate': 'CC 8901',
      'model': 'Camry 2.5 HEV',
      'type': '4 Door Car',
      'address': '333 Siam Square, Pathum Wan, Bangkok 10330',
      'price': 300,
      'icon': Icons.directions_car,
      'color': Color(0xFF16213E),
    },
    {
      'name': "Nari's Mazda",
      'rating': 4.0,
      'plate': 'DD 2345',
      'model': 'Mazda 3 Hatchback',
      'type': 'Hatchback',
      'address': '444 Sukhumvit Rd, Khlong Toei, Bangkok 10110',
      'price': 220,
      'icon': Icons.directions_car,
      'color': Color(0xFF1A1A2E),
    },
    {
      'name': "Krit's BMW",
      'rating': 4.8,
      'plate': 'EE 6789',
      'model': 'X3 xDrive30e',
      'type': 'SUV',
      'address': '555 Silom Rd, Bang Rak, Bangkok 10500',
      'price': 450,
      'icon': Icons.directions_car,
      'color': Color(0xFF4A1942),
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
                child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RenterCarDetailPage(car: _topCars[index]),
                      ),
                    );
                  },
                  child: _buildCarCard(_topCars[index]),
                ),
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

  // ─────────── Car Card ───────────
  Widget _buildCarCard(Map<String, dynamic> car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              (car['color'] as Color).withValues(alpha: 0.9),
              (car['color'] as Color).withValues(alpha: 0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (car['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with rating
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      car['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          (car['rating'] as num).toString(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content row: image + details
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car image placeholder
                  Container(
                    width: 110,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Icon(
                        car['icon'] as IconData,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(Icons.credit_card, 'License plate: ${car['plate']}'),
                        const SizedBox(height: 3),
                        _detailRow(Icons.directions_car_outlined, 'Model: ${car['model']}'),
                        const SizedBox(height: 3),
                        _detailRow(Icons.category_outlined, 'Type: ${car['type']}'),
                        const SizedBox(height: 3),
                        _detailRow(Icons.location_on_outlined, car['address'] as String),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Price ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              '${car['price']} ฿ / Hr.',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFC107),
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

  Widget _detailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
