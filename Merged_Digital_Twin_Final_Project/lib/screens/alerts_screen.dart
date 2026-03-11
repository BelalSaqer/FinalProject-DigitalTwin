import 'package:flutter/material.dart';

import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';

enum AlertSeverity { info, warning, critical }
enum AlertStatus { active, resolved }

class AlertItem {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertStatus status;
  final String machineName;
  final String time;

  const AlertItem({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.machineName,
    required this.time,
  });
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String filter = 'all';

  static const List<AlertItem> _alerts = <AlertItem>[
    AlertItem(
      id: 'a1',
      title: 'Overheat Detected',
      description: 'Temperature exceeded safe threshold (78°C).',
      severity: AlertSeverity.critical,
      status: AlertStatus.active,
      machineName: 'CNC Machine A1',
      time: '2 min ago',
    ),
    AlertItem(
      id: 'a2',
      title: 'Vibration Spike',
      description: 'Unexpected vibration pattern detected.',
      severity: AlertSeverity.warning,
      status: AlertStatus.active,
      machineName: 'Press Machine C1',
      time: '18 min ago',
    ),
    AlertItem(
      id: 'a3',
      title: 'Maintenance Due',
      description: 'Scheduled service is approaching.',
      severity: AlertSeverity.info,
      status: AlertStatus.resolved,
      machineName: 'Lathe Machine E1',
      time: 'Yesterday',
    ),
    AlertItem(
      id: 'a4',
      title: 'Power Fluctuation',
      description: 'Input power variance above baseline.',
      severity: AlertSeverity.warning,
      status: AlertStatus.resolved,
      machineName: 'Robotic Arm B2',
      time: '2 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final alerts = _alerts.where((a) {
      if (filter == 'all') return true;
      if (filter == 'active') return a.status == AlertStatus.active;
      if (filter == 'resolved') return a.status == AlertStatus.resolved;
      return true;
    }).toList();

    return Scaffold(
      appBar: appHeader(title: 'Alerts', subtitle: 'System notifications'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        children: [
          _FilterTabs(
            current: filter,
            onChange: (v) => setState(() => filter = v),
          ),
          const SizedBox(height: 16),
          ...alerts.map(
                (a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AlertCard(alert: a),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChange;
  const _FilterTabs({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const tabs = [_Tab('all', 'All'), _Tab('active', 'Active'), _Tab('resolved', 'Resolved')];

    return GlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: tabs.map((t) {
          final selected = current == t.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(t.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? DT.blue.alphaF(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  t.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? DT.blue : DT.muted(0.55),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Tab {
  final String key;
  final String label;
  const _Tab(this.key, this.label);
}

class _AlertCard extends StatelessWidget {
  final AlertItem alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final ui = _SeverityUI.of(alert.severity);
    final isResolved = alert.status == AlertStatus.resolved;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ui.color.alphaF(0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ui.color.alphaF(0.26)),
                ),
                child: Icon(ui.icon, color: ui.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(
                      alert.machineName,
                      style: TextStyle(color: DT.muted(0.50), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              _Badge(text: alert.severity.name.toUpperCase(), color: ui.color),
            ],
          ),
          const SizedBox(height: 12),
          Text(alert.description, style: TextStyle(color: DT.muted(0.55))),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(alert.time, style: TextStyle(color: DT.muted(0.45), fontSize: 12)),
              const Spacer(),
              if (!isResolved)
                TextButton(onPressed: () {}, child: const Text('Acknowledge'))
              else
                Text('Resolved', style: TextStyle(color: DT.muted(0.45), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.alphaF(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.alphaF(0.26)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}

class _SeverityUI {
  final Color color;
  final IconData icon;
  const _SeverityUI(this.color, this.icon);

  static _SeverityUI of(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.info:
        return const _SeverityUI(DT.blue, Icons.info_rounded);
      case AlertSeverity.warning:
        return const _SeverityUI(DT.yellow, Icons.warning_rounded);
      case AlertSeverity.critical:
        return const _SeverityUI(DT.red, Icons.error_rounded);
    }
  }
}