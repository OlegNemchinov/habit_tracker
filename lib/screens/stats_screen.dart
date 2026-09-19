import 'package:flutter/material.dart';
import '../database_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _db.getWeeklyStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Последние 7 дней',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _buildWeekRow(),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildWeekRow() {
    final now = DateTime.now();
    final widgets = <Widget>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final count = _stats[dateStr] ?? 0;
      final hasCompletion = count > 0;
      final isToday = i == 0;

      widgets.add(
        Column(
          children: [
            Text(
              _weekday(date.weekday),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                color: isToday ? const Color(0xFF4CAF50) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasCompletion
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[200],
                border: isToday
                    ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                    : null,
              ),
              child: hasCompletion
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(height: 4),
            Text('${date.day}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      );
    }
    return widgets;
  }

  String _weekday(int day) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[day - 1];
  }
}