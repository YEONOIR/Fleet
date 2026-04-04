import 'package:flutter/material.dart';
import 'renter_car_detail.dart';  

class RenterSearchPage extends StatefulWidget {
  const RenterSearchPage({super.key});

  @override
  State<RenterSearchPage> createState() => _RenterSearchPageState();
}

class _RenterSearchPageState extends State<RenterSearchPage>
    with SingleTickerProviderStateMixin {
  // ── Search state ──
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // ── Filter state ──
  String? _selectedVehicleType; // null = all types

  // ── Calendar state ──
  bool _isCalendarOpen = false;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _calendarMonth = DateTime(2022, 1, 1); // default January 2022

  // ── Vehicle type options ──
  static const List<Map<String, dynamic>> _vehicleTypes = [
    {'label': 'Car', 'icon': Icons.directions_car, 'type': 'Car'},
    {'label': 'Motorcycle', 'icon': Icons.two_wheeler, 'type': 'Motorcycle'},
    {'label': 'Van', 'icon': Icons.airport_shuttle, 'type': 'Van'},
  ];

  // ── Mock vehicles with availability periods ──
  static final List<Map<String, dynamic>> _allVehicles = [
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'vehicleType': 'Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 5),
      'availableTo': DateTime(2022, 1, 20),
      'color': Color(0xFF1A1A2E),
    },
    {
      'name': "Pimthida's Bike",
      'rating': 4.5,
      'plate': 'BB 567',
      'model': 'GRAND FILANO HYBRID',
      'type': 'Motorcycle',
      'vehicleType': 'Motorcycle',
      'address': '222 JJ Village, Loo Road, Llama, Penguin, Bangkok 10120',
      'price': 300,
      'image': 'assets/images/bike.jpg',
      'availableFrom': DateTime(2022, 1, 8),
      'availableTo': DateTime(2022, 1, 25),
      'color': Color(0xFF4A1942),
    },
    {
      'name': "Aran's Toyota",
      'rating': 4.3,
      'plate': 'CC 8901',
      'model': 'Camry 2.5 HEV',
      'type': '4 Door Car',
      'vehicleType': 'Car',
      'address': '333 Siam Square, Pathum Wan, Bangkok 10330',
      'price': 300,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 1),
      'availableTo': DateTime(2022, 1, 15),
      'color': Color(0xFF16213E),
    },
    {
      'name': "Nari's Mazda",
      'rating': 4.0,
      'plate': 'DD 2345',
      'model': 'Mazda 3 Hatchback',
      'type': 'Hatchback',
      'vehicleType': 'Car',
      'address': '444 Sukhumvit Rd, Khlong Toei, Bangkok 10110',
      'price': 220,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 12),
      'availableTo': DateTime(2022, 2, 5),
      'color': Color(0xFF1A1A2E),
    },
    {
      'name': "Krit's BMW",
      'rating': 4.8,
      'plate': 'EE 6789',
      'model': 'X3 xDrive30e',
      'type': 'SUV',
      'vehicleType': 'Car',
      'address': '555 Silom Rd, Bang Rak, Bangkok 10500',
      'price': 450,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 3),
      'availableTo': DateTime(2022, 1, 30),
      'color': Color(0xFF4A1942),
    },
    {
      'name': "Somchai's Van",
      'rating': 4.2,
      'plate': 'FF 3456',
      'model': 'Commuter HiAce',
      'type': 'Van',
      'vehicleType': 'Van',
      'address': '666 Ratchadaphisek Rd, Bangkok 10310',
      'price': 500,
      'image': 'assets/images/car2.jpg',
      'availableFrom': DateTime(2022, 1, 1),
      'availableTo': DateTime(2022, 1, 28),
      'color': Color(0xFF16213E),
    },
    {
      'name': "Dao's Bike",
      'rating': 4.6,
      'plate': 'GG 7890',
      'model': 'PCX 160',
      'type': 'Motorcycle',
      'vehicleType': 'Motorcycle',
      'address': '777 Rama 9 Rd, Bangkok 10320',
      'price': 150,
      'image': 'assets/images/bike.jpg',
      'availableFrom': DateTime(2022, 1, 10),
      'availableTo': DateTime(2022, 2, 10),
      'color': Color(0xFF4A1942),
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _isSearchExpanded = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Filter logic ──
  List<Map<String, dynamic>> get _filteredVehicles {
    List<Map<String, dynamic>> results = List.from(_allVehicles);

    // Filter by search text
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      results = results.where((v) {
        final name = (v['name'] as String).toLowerCase();
        final model = (v['model'] as String).toLowerCase();
        final plate = (v['plate'] as String).toLowerCase();
        return name.contains(query) ||
            model.contains(query) ||
            plate.contains(query);
      }).toList();
    }

    // Filter by vehicle type
    if (_selectedVehicleType != null) {
      results = results
          .where((v) => v['vehicleType'] == _selectedVehicleType)
          .toList();
    }

    // Filter by date range availability
    if (_startDate != null && _endDate != null) {
      results = results.where((v) {
        final availFrom = v['availableFrom'] as DateTime;
        final availTo = v['availableTo'] as DateTime;
        // Vehicle must be available for the entire booking period
        return !availFrom.isAfter(_startDate!) && !availTo.isBefore(_endDate!);
      }).toList();
    }

    return results;
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start new selection
        _startDate = date;
        _endDate = null;
      } else {
        // Set end date
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredVehicles;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context),

          // ── Calendar (expandable) ──
          if (_isCalendarOpen) _buildCalendar(),

          // ── Content ──
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length + 1, // +1 for title
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Highlight',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF070E2A),
                                ),
                              ),
                              if (_selectedVehicleType != null ||
                                  _startDate != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedVehicleType = null;
                                      _startDate = null;
                                      _endDate = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.clear,
                                            size: 14,
                                            color: Color(0xFF7B1FA2)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Clear filters',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF7B1FA2),
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RenterCarDetailPage(car: filtered[index - 1]),
                              ),
                            );
                          },
                          child: _buildVehicleCard(filtered[index - 1]),
                        ),
                      );
                    },
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
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
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
      child: Row(
        children: [
          // Search icon / expanded search bar
          if (_isSearchExpanded)
            Expanded(
              child: _buildExpandedSearch(),
            )
          else
            _buildCollapsedSearch(),

          // Spacer pushes filter+calendar to right when collapsed
          if (!_isSearchExpanded) const Spacer(),

          const SizedBox(width: 12),

          // Filter button
          _buildHeaderIcon(
            icon: Icons.filter_alt,
            isActive: _selectedVehicleType != null,
            onTap: () => _showFilterSheet(),
          ),
          const SizedBox(width: 8),

          // Calendar button
          _buildHeaderIcon(
            icon: Icons.calendar_today,
            isActive: _startDate != null,
            onTap: () {
              setState(() {
                _isCalendarOpen = !_isCalendarOpen;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSearch() {
    return GestureDetector(
      key: const ValueKey('collapsed'),
      onTap: () {
        setState(() => _isSearchExpanded = true);
        Future.delayed(const Duration(milliseconds: 100), () {
          _searchFocusNode.requestFocus();
        });
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Icon(
          Icons.search,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildExpandedSearch() {
    return Container(
      key: const ValueKey('expanded'),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color(0xFF070E2A),
        ),
        decoration: InputDecoration(
          hintText: 'Enter Search',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: const Color(0xFF070E2A).withValues(alpha: 0.4),
          ),
          prefixIcon: GestureDetector(
            onTap: () {
              if (_searchController.text.isEmpty) {
                setState(() => _isSearchExpanded = false);
                _searchFocusNode.unfocus();
              }
            },
            child: const Icon(
              Icons.search,
              color: Color(0xFFAC72A1),
              size: 22,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.clear,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF7B1FA2) : Colors.white,
          size: 22,
        ),
      ),
    );
  }

  // ─────────── Filter Bottom Sheet ───────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Filter by Vehicle Type',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF070E2A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle type chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _vehicleTypes.map((vt) {
                      final isSelected =
                          _selectedVehicleType == vt['type'];
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            setState(() {
                              _selectedVehicleType = isSelected
                                  ? null
                                  : vt['type'] as String;
                            });
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF070E2A)
                                : const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF070E2A)
                                  : const Color(0xFFCE93D8),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                vt['icon'] as IconData,
                                size: 20,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF070E2A),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                vt['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF070E2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFAC72A1),
                            Color(0xFF070E2A),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Apply Filter',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────── Calendar ───────────
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _monthYearString(_calendarMonth),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF070E2A),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _calendarMonth = DateTime(
                          _calendarMonth.year,
                          _calendarMonth.month - 1,
                        );
                      });
                    },
                    child: const Icon(Icons.chevron_left,
                        color: Color(0xFF070E2A), size: 28),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _calendarMonth = DateTime(
                          _calendarMonth.year,
                          _calendarMonth.month + 1,
                        );
                      });
                    },
                    child: const Icon(Icons.chevron_right,
                        color: Color(0xFF070E2A), size: 28),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayLabel('Sun'),
              _DayLabel('Mon'),
              _DayLabel('Tue'),
              _DayLabel('Wed'),
              _DayLabel('Thu'),
              _DayLabel('Fri'),
              _DayLabel('Sat'),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar grid
          _buildCalendarGrid(),

          // Selected date info
          if (_startDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.date_range,
                      size: 16, color: Color(0xFF7B1FA2)),
                  const SizedBox(width: 8),
                  Text(
                    _endDate != null
                        ? '${_formatDate(_startDate!)} – ${_formatDate(_endDate!)}'
                        : '${_formatDate(_startDate!)} – Select end date',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final lastDay =
        DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // Sun=0

    // Previous month trailing days
    final prevMonthLastDay =
        DateTime(_calendarMonth.year, _calendarMonth.month, 0);

    List<Widget> rows = [];
    List<Widget> cells = [];

    // Fill leading empty cells with previous month
    for (int i = 0; i < startWeekday; i++) {
      final day = prevMonthLastDay.day - startWeekday + 1 + i;
      cells.add(_buildDayCell(day, isCurrentMonth: false));
    }

    // Current month days
    for (int day = 1; day <= lastDay.day; day++) {
      final date =
          DateTime(_calendarMonth.year, _calendarMonth.month, day);
      cells.add(_buildDayCell(day,
          isCurrentMonth: true, date: date));

      if (cells.length == 7) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cells,
        ));
        cells = [];
      }
    }

    // Next month leading days
    if (cells.isNotEmpty) {
      int nextDay = 1;
      while (cells.length < 7) {
        cells.add(
            _buildDayCell(nextDay++, isCurrentMonth: false));
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: cells,
      ));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(int day,
      {required bool isCurrentMonth, DateTime? date}) {
    if (!isCurrentMonth) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    final isStart = _startDate != null &&
        date != null &&
        _isSameDay(date, _startDate!);
    final isEnd = _endDate != null &&
        date != null &&
        _isSameDay(date, _endDate!);
    final isInRange = _startDate != null &&
        _endDate != null &&
        date != null &&
        date.isAfter(_startDate!) &&
        date.isBefore(_endDate!);

    return GestureDetector(
      onTap: date != null ? () => _onDateTap(date) : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: (isStart || isEnd) ? BoxShape.circle : BoxShape.rectangle,
          color: (isStart || isEnd)
              ? const Color(0xFF070E2A)
              : isInRange
                  ? const Color(0xFFE1BEE7).withValues(alpha: 0.5)
                  : Colors.transparent,
          borderRadius:
              (isStart || isEnd) ? null : BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight:
                  (isStart || isEnd) ? FontWeight.w700 : FontWeight.w400,
              color: (isStart || isEnd)
                  ? Colors.white
                  : isInRange
                      ? const Color(0xFF7B1FA2)
                      : const Color(0xFF070E2A),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────── Vehicle Card ───────────
  Widget _buildVehicleCard(Map<String, dynamic> car) {
    final color = car['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
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
                color: color,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + rating
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

              // Image + details
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
                          _detailRow(Icons.credit_card,
                              'License plate: ${car['plate']}'),
                          const SizedBox(height: 3),
                          _detailRow(Icons.directions_car_outlined,
                              'Model: ${car['model']}'),
                          const SizedBox(height: 3),
                          _detailRow(Icons.category_outlined,
                              'Type: ${car['type']}'),
                          const SizedBox(height: 3),
                          _detailRow(Icons.location_on_outlined,
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
            ],
          ),
        ),
      ),
    );
  }

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

  // ─────────── Empty State ───────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No vehicles found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters or dates',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Helpers ───────────
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthYearString(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ─────────── Day Label Widget ───────────
class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF070E2A),
          ),
        ),
      ),
    );
  }
}
