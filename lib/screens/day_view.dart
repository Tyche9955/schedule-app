import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_provider.dart';

class DayView extends StatelessWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EventProvider>();
    final date = ep.selectedDate;

    return Column(
      children: [
        _buildHeader(context, ep, date),
        Expanded(
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (ctx, hour) {
              final eventsAtHour = ep.eventsForSelectedDate.where((e) =>
                !e.isAllDay && e.startTime != null && e.startTime!.hour == hour
              ).toList();
              return _buildHourRow(context, hour, eventsAtHour);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, EventProvider ep, DateTime date) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => ep.selectDate(date.subtract(Duration(days: 1))),
          ),
          GestureDetector(
            onTap: () => ep.setFocusedMonth(date),
            child: Text(
              DateFormat('M月d日 E').format(date),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => ep.selectDate(date.add(Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildHourRow(BuildContext context, int hour, List events) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${hour.toString().padLeft(2,'0')}:00',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? Divider(height: 1)
                : Column(
                    children: events.map<Widget>((e) =>
                      Container(
                        margin: EdgeInsets.only(bottom: 2),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: e.color.withAlpha(50),
                          border: Border.all(color: e.color, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(e.title, style: TextStyle(fontSize: 12, color: e.color), overflow: TextOverflow.ellipsis),
                      )
                    ).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
