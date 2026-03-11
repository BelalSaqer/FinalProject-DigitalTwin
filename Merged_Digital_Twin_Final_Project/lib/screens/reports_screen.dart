import 'package:flutter/material.dart';

import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';

enum ReportKind { performance, alerts, maintenance, summary }

class ReportItem {
  final String id;
  final String title;
  final ReportKind kind;
  final String period;
  final String date;
  final String size;

  const ReportItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.period,
    required this.date,
    required this.size,
  });
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  /// ✅ بيانات داخل الملف (بدون reportsMock)
  static const List<ReportItem> _reports = <ReportItem>[
    ReportItem(id: 'r1', title: 'Weekly Performance', kind: ReportKind.performance, period: 'Last 7 days', date: 'Today', size: '1.2 MB'),
    ReportItem(id: 'r2', title: 'Alerts Summary', kind: ReportKind.alerts, period: 'Last 24 hours', date: 'Yesterday', size: '640 KB'),
    ReportItem(id: 'r3', title: 'Maintenance Log', kind: ReportKind.maintenance, period: 'Last 30 days', date: '2 days ago', size: '2.6 MB'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appHeader(title: 'Reports', subtitle: 'Generate & download'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        children: [
          GradientButton(
            text: 'Generate New Report',
            icon: Icons.auto_awesome_rounded,
            onTap: () {},
          ),
          const SizedBox(height: 16),

          const Text('Quick Templates', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          Row(
            children: const [
              Expanded(child: _TemplateCard(title: 'Performance', subtitle: 'Last 7 days', icon: Icons.speed_rounded, color: DT.blue)),
              SizedBox(width: 12),
              Expanded(child: _TemplateCard(title: 'Alerts', subtitle: 'Last 24 hours', icon: Icons.notifications_rounded, color: DT.yellow)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _TemplateCard(title: 'Maintenance', subtitle: 'Last 30 days', icon: Icons.build_rounded, color: DT.green)),
              SizedBox(width: 12),
              Expanded(child: _TemplateCard(title: 'Summary', subtitle: 'Overview', icon: Icons.insert_chart_outlined_rounded, color: DT.purple)),
            ],
          ),

          const SizedBox(height: 18),
          const Text('Recent Reports', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          ..._reports.map(
                (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReportRow(item: r),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.alphaF(0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.alphaF(0.26)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: DT.muted(0.55))),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final ReportItem item;
  const _ReportRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final ui = _ReportUI.of(item.kind);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ui.color.alphaF(0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ui.color.alphaF(0.26)),
            ),
            child: Icon(ui.icon, color: ui.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  '${item.period} • ${item.date} • ${item.size}',
                  style: TextStyle(color: DT.muted(0.50), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DT.surface(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DT.border(0.45)),
              ),
              child: Icon(Icons.download_rounded, color: DT.cyan, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportUI {
  final Color color;
  final IconData icon;
  const _ReportUI(this.color, this.icon);

  static _ReportUI of(ReportKind k) {
    switch (k) {
      case ReportKind.performance:
        return const _ReportUI(DT.blue, Icons.speed_rounded);
      case ReportKind.alerts:
        return const _ReportUI(DT.yellow, Icons.notifications_rounded);
      case ReportKind.maintenance:
        return const _ReportUI(DT.green, Icons.build_rounded);
      case ReportKind.summary:
        return const _ReportUI(DT.purple, Icons.insert_chart_outlined_rounded);
    }
  }
}