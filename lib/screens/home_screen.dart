import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'month_calendar.dart';
import 'day_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showMonth = true;

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EventProvider>();
    final today = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('日程管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showMonth ? Icons.view_day : Icons.calendar_month),
            onPressed: () => setState(() => _showMonth = !_showMonth),
            tooltip: _showMonth ? '日视图' : '月视图',
          ),
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () => ep.selectDate(today),
            tooltip: '今天',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showMonth) Expanded(flex: 2, child: MonthCalendar())
          else Expanded(flex: 2, child: DayView()),
          Divider(height: 1),
          Expanded(flex: 3, child: _buildEventList(ep)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/event/add'),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList(EventProvider ep) {
    final events = ep.eventsForSelectedDate;
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              '暂无日程',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            Text(
              '点击下方 + 添加新日程',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (ctx, i) {
        final e = events[i];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 4, height: 40,
              decoration: BoxDecoration(
                color: e.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(e.title, style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(e.timeRangeStr),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => ep.deleteEvent(e.id),
            ),
            onTap: () => Navigator.pushNamed(ctx, '/event/edit', arguments: e),
          ),
        );
      },
    );
  }
}
