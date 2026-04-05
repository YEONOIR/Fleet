import 'package:flutter/material.dart';

class SearchCalendar extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime calendarMonth;
  final ValueChanged<DateTime> onDateTap;
  final ValueChanged<DateTime> onMonthChanged;

  const SearchCalendar({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.calendarMonth,
    required this.onDateTap,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                _monthYearString(calendarMonth),
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
                    onTap: () => onMonthChanged(DateTime(calendarMonth.year, calendarMonth.month - 1)),
                    child: const Icon(Icons.chevron_left, color: Color(0xFF070E2A), size: 28),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onMonthChanged(DateTime(calendarMonth.year, calendarMonth.month + 1)),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF070E2A), size: 28),
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
              _DayLabel('Sun'), _DayLabel('Mon'), _DayLabel('Tue'),
              _DayLabel('Wed'), _DayLabel('Thu'), _DayLabel('Fri'), _DayLabel('Sat'),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar grid
          _buildCalendarGrid(),

          // Selected date info
          if (startDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.date_range, size: 16, color: Color(0xFF7B1FA2)),
                  const SizedBox(width: 8),
                  Text(
                    endDate != null
                        ? '${_formatDate(startDate!)} – ${_formatDate(endDate!)}'
                        : '${_formatDate(startDate!)} – Select end date',
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
    final firstDay = DateTime(calendarMonth.year, calendarMonth.month, 1);
    final lastDay = DateTime(calendarMonth.year, calendarMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // Sun=0

    final prevMonthLastDay = DateTime(calendarMonth.year, calendarMonth.month, 0);

    List<Widget> rows = [];
    List<Widget> cells = [];

    for (int i = 0; i < startWeekday; i++) {
      final day = prevMonthLastDay.day - startWeekday + 1 + i;
      cells.add(_buildDayCell(day, isCurrentMonth: false));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(calendarMonth.year, calendarMonth.month, day);
      cells.add(_buildDayCell(day, isCurrentMonth: true, date: date));

      if (cells.length == 7) {
        rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: cells));
        cells = [];
      }
    }

    if (cells.isNotEmpty) {
      int nextDay = 1;
      while (cells.length < 7) {
        cells.add(_buildDayCell(nextDay++, isCurrentMonth: false));
      }
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: cells));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(int day, {required bool isCurrentMonth, DateTime? date}) {
    if (!isCurrentMonth) {
      return SizedBox(
        width: 40, height: 40,
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.withValues(alpha: 0.4)),
          ),
        ),
      );
    }

    final isStart = startDate != null && date != null && _isSameDay(date, startDate!);
    final isEnd = endDate != null && date != null && _isSameDay(date, endDate!);
    final isInRange = startDate != null && endDate != null && date != null &&
        date.isAfter(startDate!) && date.isBefore(endDate!);

    return GestureDetector(
      onTap: date != null ? () => onDateTap(date) : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: (isStart || isEnd) ? BoxShape.circle : BoxShape.rectangle,
          color: (isStart || isEnd)
              ? const Color(0xFF070E2A)
              : isInRange ? const Color(0xFFE1BEE7).withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: (isStart || isEnd) ? null : BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: (isStart || isEnd) ? FontWeight.w700 : FontWeight.w400,
              color: (isStart || isEnd) ? Colors.white : isInRange ? const Color(0xFF7B1FA2) : const Color(0xFF070E2A),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthYearString(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

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
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF070E2A)),
        ),
      ),
    );
  }
}