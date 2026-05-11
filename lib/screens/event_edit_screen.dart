import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class EventEditScreen extends StatefulWidget {
  final Event? event;
  const EventEditScreen({super.key, this.event});
  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late DateTime _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late int _colorIndex;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.event?.title ?? '');
    _descCtrl = TextEditingController(text: widget.event?.description ?? '');
    _date = widget.event?.date ?? context.read<EventProvider>().selectedDate;
    _startTime = widget.event?.startTime;
    _endTime = widget.event?.endTime;
    _colorIndex = widget.event?.colorIndex ?? 0;
    _isAllDay = widget.event?.isAllDay ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑日程' : '新建日程'),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: '日程标题 *',
              border: OutlineInputBorder(),
            ),
            autofocus: !isEdit,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            decoration: InputDecoration(
              labelText: '描述（可选）',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('日期'),
            subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('全天事件'),
            value: _isAllDay,
            onChanged: (v) => setState(() => _isAllDay = v),
          ),
          if (!_isAllDay) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('开始时间'),
              subtitle: Text(_startTime == null ? '未设置' : _fmtTime(_startTime!)),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: _startTime ?? TimeOfDay.now());
                if (t != null) setState(() => _startTime = t);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('结束时间'),
              subtitle: Text(_endTime == null ? '未设置' : _fmtTime(_endTime!)),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: _endTime ?? _startTime ?? TimeOfDay.now());
                if (t != null) setState(() => _endTime = t);
              },
            ),
          ],
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('颜色标签', style: TextStyle(fontSize: 14)),
          ),
          Wrap(
            spacing: 10,
            children: List.generate(Event.eventColors.length, (i) =>
              GestureDetector(
                onTap: () => setState(() => _colorIndex = i),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Event.eventColors[i],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _colorIndex == i ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: _colorIndex == i
                        ? [BoxShadow(color: Event.eventColors[i].withAlpha(150), blurRadius: 6)]
                        : null,
                  ),
                  child: _colorIndex == i ? Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Padding(padding: EdgeInsets.all(12), child: Text(isEdit ? '保存修改' : '添加日程', style: TextStyle(fontSize: 16))),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  String _fmtTime(TimeOfDay t) => '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请输入标题')));
      return;
    }
    final ep = context.read<EventProvider>();
    final event = Event(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      colorIndex: _colorIndex,
      isAllDay: _isAllDay,
    );
    if (widget.event != null) {
      ep.updateEvent(event);
    } else {
      ep.addEvent(event);
    }
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除日程'),
        content: Text('确定要删除这个日程吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(
            onPressed: () {
              context.read<EventProvider>().deleteEvent(widget.event!.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
