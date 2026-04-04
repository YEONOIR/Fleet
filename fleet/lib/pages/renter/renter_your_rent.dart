import 'package:flutter/material.dart';
import 'renter_schedule_detail.dart';

class RenterYourRentPage extends StatefulWidget {
  const RenterYourRentPage({super.key});

  @override
  State<RenterYourRentPage> createState() => _RenterYourRentPageState();
}

class _RenterYourRentPageState extends State<RenterYourRentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Tab definitions ──
  static const List<String> _tabLabels = [
    'Accept',
    'Using',
    'Complete',
    'Cancel',
    'Pending',
  ];

  static const List<Color> _tabColors = [
    Color(0xFF2E7D6E), // Accept – teal
    Color(0xFF7B1FA2), // Using – purple
    Color(0xFFAC72A1), // Complete – lavender pink
    Color(0xFFC62828), // Cancel – red
    Color(0xFFE6A817), // Pending – amber gold
  ];

  // ── Border gradient pairs per tab ──
  static const List<List<Color>> _cardBorderGradients = [
    [Color(0xFF4A1942), Color(0xFFAC72A1)], // Accept
    [Color(0xFF1A237E), Color(0xFF7B1FA2)], // Using
    [Color(0xFFAC72A1), Color(0xFFE1BEE7)], // Complete
    [Color(0xFF4A1942), Color(0xFFC62828)], // Cancel
    [Color(0xFFE6A817), Color(0xFFFFF176)], // Pending
  ];

  // ── Mock rent data ──
  // Each item has a 'status' field matching a tab index
  List<Map<String, dynamic>> _rentData = [
    // ── Accept (index 0) ──
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'status': 0,
    },
    {
      'name': "Aran's Toyota",
      'rating': 4.3,
      'plate': 'CC 8901',
      'model': 'Camry 2.5 HEV',
      'type': '4 Door Car',
      'address': '333 Siam Square, Pathum Wan, Bangkok 10330',
      'price': 300,
      'image': 'assets/images/car.jpg',
      'status': 0,
    },

    // ── Using (index 1) ──
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'status': 1,
    },

    // ── Complete (index 2) ──
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'status': 2,
    },
    {
      'name': "Nari's Mazda",
      'rating': 4.0,
      'plate': 'DD 2345',
      'model': 'Mazda 3 Hatchback',
      'type': 'Hatchback',
      'address': '444 Sukhumvit Rd, Khlong Toei, Bangkok 10110',
      'price': 220,
      'image': 'assets/images/car.jpg',
      'status': 2,
    },

    // ── Cancel (index 3) ──
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'status': 3,
    },

    // ── Pending (index 4) ──
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'status': 4,
    },
    {
      'name': "Krit's BMW",
      'rating': 4.8,
      'plate': 'EE 6789',
      'model': 'X3 xDrive30e',
      'type': 'SUV',
      'address': '555 Silom Rd, Bang Rak, Bangkok 10500',
      'price': 450,
      'image': 'assets/images/car.jpg',
      'status': 4,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get items for a given tab index
  List<Map<String, dynamic>> _itemsForTab(int tabIndex) {
    return _rentData.where((e) => e['status'] == tabIndex).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context),

          // ── Tab bar ──
          _buildTabBar(),

          // ── Tab content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(5, (tabIndex) {
                return _buildTabContent(tabIndex);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Header ───────────
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
      child: const Center(
        child: Text(
          'Your rent',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─────────── Tab Bar ───────────
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelPadding: EdgeInsets.zero,
        indicatorColor: _tabColors[_tabController.index],
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelColor: _tabColors[_tabController.index],
        unselectedLabelColor: const Color(0xFF999999),
        tabs: List.generate(5, (i) {
          return Tab(text: _tabLabels[i]);
        }),
      ),
    );
  }

  // ─────────── Tab Content ───────────
  Widget _buildTabContent(int tabIndex) {
    final items = _itemsForTab(tabIndex);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No ${_tabLabels[tabIndex].toLowerCase()} rentals',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () async {
              // 💡 พากดเข้าหน้ารายละเอียด และรอรับค่าสถานะใหม่กลับมา
              final newStatus = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RenterScheduleDetailPage(booking: items[index]),
                ),
              );
              
              // 💡 ถ้ามีการอัปเดตสถานะ เช่น จาก 0 (Accept) กลายเป็น 1 (Using) หรือ 3 (Cancel)
              // ให้ทำการ setState อัปเดตค่าในลิสต์หลัก
              if (newStatus != null && newStatus is int) {
                setState(() {
                  // หา index ดั้งเดิมใน _rentData แล้วอัปเดต
                  int originalIndex = _rentData.indexOf(items[index]);
                  if (originalIndex != -1) {
                    _rentData[originalIndex]['status'] = newStatus;
                  }
                });
                // 💡 สลับ Tab ไปหน้าใหม่ให้อัตโนมัติด้วย
                _tabController.animateTo(newStatus);
              }
            },
            child: _buildRentCard(items[index], tabIndex),
          ),
        );
      },
    );
  }

  // ─────────── Rent Card ───────────
  Widget _buildRentCard(Map<String, dynamic> car, int tabIndex) {
    final gradientColors = _cardBorderGradients[tabIndex];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: gradientColors[0],
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row + rating badge ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
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
                          color: Color(0xFF070E2A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.white),
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

              // ── Content row: image + details ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car image
                    Container(
                      width: 100,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          car['image'] as String,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(
                              Icons.credit_card,
                              'License plate: ${car['plate']}'),
                          const SizedBox(height: 3),
                          _detailRow(
                              Icons.directions_car_outlined,
                              'Model: ${car['model']}'),
                          const SizedBox(height: 3),
                          _detailRow(
                              Icons.category_outlined,
                              'Type: ${car['type']}'),
                          const SizedBox(height: 3),
                          _detailRow(
                              Icons.location_on_outlined,
                              car['address'] as String),
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
                                  color: const Color(0xFF070E2A)
                                      .withValues(alpha: 0.6),
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

              // ── Status indicator bar at bottom ──
              Container(
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────── Detail Row ───────────
  Widget _detailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 14,
            color: const Color(0xFF070E2A).withValues(alpha: 0.5)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF070E2A).withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
