import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EventProvider>();
    final month = ep.focusedMonth;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final days = List.generate(42, (i) {
      final day = i - firstWeekday + 1;
      if (day < 1 || day > daysInMonth) return null;
      return DateTime(month.year, month.month, day);
    });

    return Column(
      children: [
        _buildHeader(context, ep, month),
        _buildWeekdayRow(),
        Expanded(
          child: GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 1,
            physics: NeverScrollableScrollPhysics(),
            children: days.map((d) => d == null ? SizedBox() : _buildDayCell(context, ep, d)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, EventProvider ep, DateTime month) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => ep.setFocusedMonth(DateTime(month.year, month.month - 1)),
          ),
          GestureDetector(
            onTap: () => ep.setFocusedMonth(DateTime.now()),
            child: Text(
              DateFormat('yyyy年 M月').format(month),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => ep.setFocusedMonth(DateTime(month.year, month.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: ['日','一','二','三','四','五','六'].map((w) =>
          Expanded(child: Center(child: Text(w, style: TextStyle(fontSize: 12, color: Colors.grey))))
        ).toList(),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, EventProvider ep, DateTime d) {
    final isToday = _isSameDay(d, DateTime.now());
    final isSelected = ep.selectedDate.year == d.year && ep.selectedDate.month == d.month && ep.selectedDate.day == d.day;
    final count = ep.getEventCountForDate(d);
    final isCurrentMonth = ep.focusedMonth.month == d.month;

    return GestureDetector(
      onTap: () => ep.selectDate(d),
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? Theme.of(context).colorScheme.primary : null,
              ),
              child: Center(
                child: Text(
                  '${d.day}',
                  style: TextStyle(
                    color: isToday ? Colors.white : (isCurrentMonth ? null : Colors.grey[400]),
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
              ),
            ),
            if (count > 0) ...[
              SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
}
