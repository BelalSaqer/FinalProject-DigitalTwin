import 'package:flutter/material.dart';

import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';

enum HistoryType { maintenance, alert, performance, system }

class HistoryEvent {
  final String id;
  final String date;
  final String time;
  final HistoryType type;
  final String title;
  final String desc;
  final String machine;

  const HistoryEvent({
    required this.id,
    required this.date,
    required this.time,
    required this.type,
    required this.title,
    required this.desc,
    required this.machine,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String q = '';
  HistoryType? filter;

  static const List<HistoryEvent> _events = <HistoryEvent>[
    HistoryEvent(id: 'h1', date: 'Today', time: '09:12', type: HistoryType.alert, title: 'Overheat Alert', desc: 'Temp peaked at 78°C', machine: 'CNC Machine A1'),
    HistoryEvent(id: 'h2', date: 'Today', time: '08:40', type: HistoryType.performance, title: 'Efficiency Improved', desc: 'Efficiency rose to 94%', machine: 'CNC Machine A1'),
    HistoryEvent(id: 'h3', date: 'Yesterday', time: '17:22', type: HistoryType.maintenance, title: 'Lubrication Completed', desc: 'Routine lubrication executed', machine: 'Conveyor System D3'),
    HistoryEvent(id: 'h4', date: 'Yesterday', time: '12:05', type: HistoryType.system, title: 'Firmware Check', desc: 'Diagnostics completed successfully', machine: 'Robotic Arm B2'),
    HistoryEvent(id: 'h5', date: '2 days ago', time: '15:31', type: HistoryType.alert, title: 'Vibration Spike', desc: 'Anomaly recorded and flagged', machine: 'Press Machine C1'),
  ];

  @override
  Widget build(BuildContext context) {
    final events = _events.where((e) {
      final okType = filter == null || e.type == filter;
      final s = q.toLowerCase();
      final okQuery = q.isEmpty ||
          e.title.toLowerCase().contains(s) ||
          e.desc.toLowerCase().contains(s) ||
          e.machine.toLowerCase().contains(s);
      return okType && okQuery;
    }).toList();

    final grouped = <String, List<HistoryEvent>>{};
    for (final e in events) {
      grouped.putIfAbsent(e.date, () => []).add(e);
    }

    return Scaffold(
      appBar: appHeader(title: 'History', subtitle: 'Timeline of events'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: DT.dim(0.55)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => q = v),
                    decoration: const InputDecoration(
                      hintText: 'Search events...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (q.isNotEmpty)
                  IconButton(
                    onPressed: () => setState(() => q = ''),
                    icon: Icon(Icons.close_rounded, color: DT.dim(0.55)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: 'All',
                  selected: filter == null,
                  onTap: () => setState(() => filter = null),
                ),
                const SizedBox(width: 10),
                _Chip(
                  label: 'Maintenance',
                  selected: filter == HistoryType.maintenance,
                  color: DT.blue,
                  onTap: () => setState(() => filter = HistoryType.maintenance),
                ),
                const SizedBox(width: 10),
                _Chip(
                  label: 'Alert',
                  selected: filter == HistoryType.alert,
                  color: DT.red,
                  onTap: () => setState(() => filter = HistoryType.alert),
                ),
                const SizedBox(width: 10),
                _Chip(
                  label: 'Performance',
                  selected: filter == HistoryType.performance,
                  color: DT.green,
                  onTap: () => setState(() => filter = HistoryType.performance),
                ),
                const SizedBox(width: 10),
                _Chip(
                  label: 'System',
                  selected: filter == HistoryType.system,
                  color: DT.yellow,
                  onTap: () => setState(() => filter = HistoryType.system),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ...grouped.entries.map((entry) {
            final date = entry.key;
            final list = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: DT.muted(0.75),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    list.length,
                        (i) => _TimelineItem(event: list[i], isLast: i == list.length - 1),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? DT.blue;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.alphaF(0.18) : DT.surface(0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? c.alphaF(0.30) : DT.border(0.45)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : DT.muted(0.55),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final HistoryEvent event;
  final bool isLast;

  const _TimelineItem({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final ui = _HistoryUI.of(event.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: ui.color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: ui.color.alphaF(0.35), blurRadius: 14)],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 64,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: DT.border(0.40),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: ui.color.alphaF(0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ui.color.alphaF(0.26)),
                      ),
                      child: Icon(ui.icon, color: ui.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      event.time,
                      style: TextStyle(color: DT.muted(0.45), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(event.desc, style: TextStyle(color: DT.muted(0.55))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: DT.dim(0.50), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.machine,
                        style: TextStyle(color: DT.muted(0.45), fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryUI {
  final Color color;
  final IconData icon;
  const _HistoryUI(this.color, this.icon);

  static _HistoryUI of(HistoryType t) {
    switch (t) {
      case HistoryType.maintenance:
        return const _HistoryUI(DT.blue, Icons.build_rounded);
      case HistoryType.alert:
        return const _HistoryUI(DT.red, Icons.warning_rounded);
      case HistoryType.performance:
        return const _HistoryUI(DT.green, Icons.trending_up_rounded);
      case HistoryType.system:
        return const _HistoryUI(DT.yellow, Icons.settings_rounded);
    }
  }
}