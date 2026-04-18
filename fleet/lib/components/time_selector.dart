import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final ValueChanged<TimeOfDay> onStartTimeSelected;
  final ValueChanged<TimeOfDay> onEndTimeSelected;

  const TimeSelector({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // กล่องเลือกเวลาเริ่มต้น
          Expanded(
            child: _buildTimeBox(
              context: context,
              label: 'Start Time',
              selectedTime: startTime,
              onSelect: () => _pickTime(context, startTime, onStartTimeSelected),
            ),
          ),
          const SizedBox(width: 16),
          // กล่องเลือกเวลาสิ้นสุด
          Expanded(
            child: _buildTimeBox(
              context: context,
              label: 'End Time',
              selectedTime: endTime,
              onSelect: () => _pickTime(context, endTime, onEndTimeSelected),
            ),
          ),
        ],
      ),
    );
  }

  // 💡 ฟังก์ชันส่วนกลางสำหรับเรียก TimePicker (ฉบับมินิมอล & คุมโทนสีชมพู)
  Future<void> _pickTime(BuildContext context, TimeOfDay? initialTime, ValueChanged<TimeOfDay> onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white, // สีพื้นหลังหน้าต่าง
              
              // 1. 💡 ปรับแต่งปุ่ม AM/PM (สีชมพูแอป & ไม่มีเส้นกรอบ)
              dayPeriodColor: MaterialStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? const Color(0xFFAC72A1) : Colors.transparent
              ),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? Colors.white : const Color(0xFF070E2A)
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide.none, // ลบเส้นกรอบดำ
              ),

              // 2. 💡 ปรับแต่งกล่องตัวเลข (สีมินิมอล & ไม่มีเส้นกรอบ)
              hourMinuteColor: MaterialStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? const Color(0xFFF3E5F5) : Colors.grey.shade100
              ),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? const Color(0xFFAC72A1) : const Color(0xFF070E2A)
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide.none, // ลบเส้นกรอบดำ
              ),

              // 3. 💡 ตั้งค่าหน้าปัดนาฬิกา
              dialHandColor: const Color(0xFFAC72A1), // สีเข็มนาฬิกาสีชมพู
              dialBackgroundColor: Colors.grey.shade50, // สีพื้นหน้าปัด
              dialTextColor: MaterialStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? Colors.white : const Color(0xFF070E2A)
              ),

              // สีปุ่ม Cancel / OK ด้านล่าง
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade500,
                textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFFAC72A1),
                textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    // ส่งค่ากลับไปเมื่อเลือกเสร็จ
    if (picked != null) {
      onSelected(picked);
    }
  }

  Widget _buildTimeBox({
    required BuildContext context,
    required String label,
    required TimeOfDay? selectedTime,
    required VoidCallback onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF070E2A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onSelect,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5), // พื้นหลังกล่องข้างนอก
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedTime != null ? const Color(0xFFAC72A1) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime != null ? selectedTime.format(context) : '-- : --',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: selectedTime != null ? FontWeight.bold : FontWeight.w500,
                    color: selectedTime != null ? const Color(0xFFAC72A1) : Colors.grey.shade600,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: selectedTime != null ? const Color(0xFFAC72A1) : Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}