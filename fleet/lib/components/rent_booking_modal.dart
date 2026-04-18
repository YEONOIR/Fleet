import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// 💡 อย่าลืมแก้ Path ของหน้า RentPayment ให้ตรงกับโปรเจกต์ของคุณนะคะ
import '../pages/renter/rent_payment.dart'; 

class RentBookingModal extends StatefulWidget {
  final Map<String, dynamic> vehicleData;

  const RentBookingModal({super.key, required this.vehicleData});

  @override
  State<RentBookingModal> createState() => _RentBookingModalState();
}

class _RentBookingModalState extends State<RentBookingModal> {
  int _currentStep = 1; // 1 = Start, 2 = End, 3 = Summary
  bool _isLoadingSlots = true;
  List<Map<String, DateTime>> _bookedSlots = [];

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _fetchBookedSlots();
  }

  // 💡 ดึงคิวทั้งหมดที่ถูกจองไปแล้ว
  Future<void> _fetchBookedSlots() async {
    try {
      String vId = widget.vehicleData['id'] ?? widget.vehicleData['vehicle_id'] ?? '';
      var snap = await FirebaseFirestore.instance.collection('bookings')
          .where('vehicle_id', isEqualTo: vId)
          .where('status', whereIn: ['pending', 'accept', 'accepted', 'using'])
          .get();

      List<Map<String, DateTime>> slots = [];
      for (var doc in snap.docs) {
        var data = doc.data();
        if (data['start_time'] != null && data['end_time'] != null) {
          slots.add({
            'start': (data['start_time'] as Timestamp).toDate(),
            'end': (data['end_time'] as Timestamp).toDate(),
          });
        }
      }

      if (mounted) {
        setState(() {
          _bookedSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      print("Error fetching slots: $e");
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  // 💡 เช็คว่าเวลานี้ถูกจองไปหรือยัง (เพื่อทำปุ่มสีเทา)
  bool _isTimeAvailable(DateTime date, TimeOfDay time) {
    DateTime checkTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    
    // ห้ามเลือกเวลาในอดีต
    if (checkTime.isBefore(DateTime.now())) return false;

    for (var slot in _bookedSlots) {
      // ถ้าเวลาที่เช็ค อยู่ระหว่างเวลาเริ่มและจบของคิวอื่น = ไม่ว่าง
      if (!checkTime.isBefore(slot['start']!) && checkTime.isBefore(slot['end']!)) {
        return false;
      }
    }
    return true;
  }

  // 💡 เช็คว่าช่วงเวลาตั้งแต่ Start ถึง End คลุมทับคิวของคนอื่นไหม
  bool _isValidSpan(DateTime startD, TimeOfDay startT, DateTime endD, TimeOfDay endT) {
    DateTime startFull = DateTime(startD.year, startD.month, startD.day, startT.hour, startT.minute);
    DateTime endFull = DateTime(endD.year, endD.month, endD.day, endT.hour, endT.minute);
    
    if (endFull.isBefore(startFull) || endFull.isAtSameMomentAs(startFull)) return false;

    for (var slot in _bookedSlots) {
      if (startFull.isBefore(slot['end']!) && endFull.isAfter(slot['start']!)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // ให้ Modal สูง 85% ของจอ
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          
          Expanded(
            child: _isLoadingSlots
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1)))
                : _buildStepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1: return _buildStartSelection();
      case 2: return _buildEndSelection();
      case 3: return _buildSummary();
      default: return const SizedBox.shrink();
    }
  }

  // ─────────── STEP 1: เลือกเวลาเริ่ม ───────────
  Widget _buildStartSelection() {
    return Column(
      children: [
        const Text('Step 1: Select Pick-up Time', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF070E2A))),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarDatePicker(
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    setState(() {
                      _startDate = date;
                      _startTime = null; // รีเซ็ตเวลาเมื่อเปลี่ยนวัน
                    });
                  },
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Text('Available Times', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildTimeGrid(
                  selectedDate: _startDate!,
                  selectedTime: _startTime,
                  onTimeSelected: (time) => setState(() => _startTime = time),
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton('Next', _startDate != null && _startTime != null ? () {
          setState(() {
            _endDate = _startDate; // ตั้งค่าเริ่มต้นให้หน้าถัดไป
            _currentStep = 2;
          });
        } : null),
      ],
    );
  }

  // ─────────── STEP 2: เลือกเวลาคืนรถ ───────────
  Widget _buildEndSelection() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => setState(() => _currentStep = 1)),
            const Expanded(child: Text('Step 2: Select Drop-off Time', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF070E2A)))),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarDatePicker(
                  initialDate: _endDate ?? _startDate!,
                  firstDate: _startDate!, // เลือกวันก่อนวันเริ่มไม่ได้
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    setState(() {
                      _endDate = date;
                      _endTime = null;
                    });
                  },
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Text('Available Times', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildTimeGrid(
                  selectedDate: _endDate ?? _startDate!,
                  selectedTime: _endTime,
                  onTimeSelected: (time) => setState(() => _endTime = time),
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton('Review Booking', _endDate != null && _endTime != null ? () {
          if (!_isValidSpan(_startDate!, _startTime!, _endDate!, _endTime!)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Invalid duration or time overlaps with another booking.'),
              backgroundColor: Colors.redAccent,
            ));
            return;
          }
          setState(() => _currentStep = 3);
        } : null),
      ],
    );
  }

  // ─────────── STEP 3: สรุปเวลา ───────────
  Widget _buildSummary() {
    final startFull = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime!.hour, _startTime!.minute);
    final endFull = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _endTime!.hour, _endTime!.minute);
    final duration = endFull.difference(startFull);
    int totalHours = duration.inHours + (duration.inMinutes % 60 > 0 ? 1 : 0);

    return Column(
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => setState(() => _currentStep = 2)),
            const Expanded(child: Text('Step 3: Booking Summary', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF070E2A)))),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSummaryRow('Pick-up', DateFormat('dd MMM yyyy, HH:mm').format(startFull), Icons.flight_takeoff),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                  _buildSummaryRow('Drop-off', DateFormat('dd MMM yyyy, HH:mm').format(endFull), Icons.flight_land),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(8)),
                    child: Text('Total Duration: $totalHours Hours', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color(0xFFAC72A1))),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildBottomButton('Confirm & Pay', () {
          Navigator.pop(context); // ปิด Modal
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => RentPaymentPage(
              vehicleData: widget.vehicleData,
              startDate: _startDate!,
              endDate: _endDate!,
              startTime: _startTime!,
              endTime: _endTime!,
            ),
          ));
        }),
      ],
    );
  }

  // ─────────── ตัวสร้างตารางเวลา ───────────
  Widget _buildTimeGrid({required DateTime selectedDate, required TimeOfDay? selectedTime, required Function(TimeOfDay) onTimeSelected}) {
    List<TimeOfDay> times = List.generate(24, (index) => TimeOfDay(hour: index, minute: 0)); // สร้างเวลา 00:00 - 23:00

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) {
        bool isAvailable = _isTimeAvailable(selectedDate, time);
        bool isSelected = selectedTime == time;
        
        return ChoiceChip(
          label: Text('${time.hour.toString().padLeft(2, '0')}:00', style: TextStyle(fontFamily: 'Poppins', color: isSelected ? Colors.white : (isAvailable ? Colors.black87 : Colors.grey))),
          selected: isSelected,
          onSelected: isAvailable ? (bool selected) => onTimeSelected(time) : null,
          selectedColor: const Color(0xFF6A65C8),
          disabledColor: Colors.grey.shade200, // 💡 ถ้าไม่ว่างจะกลายเป็นสีเทาและกดไม่ได้
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildSummaryRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6A65C8)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        )
      ],
    );
  }

  Widget _buildBottomButton(String text, VoidCallback? onPressed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A65C8),
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onPressed,
            child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}