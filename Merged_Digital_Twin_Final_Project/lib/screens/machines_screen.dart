import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/state.dart';
import '../models/machine.dart';
import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';

class MachineListScreen extends StatefulWidget {
  const MachineListScreen({super.key});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final machines = app.machines;

    final filtered = machines.where((m) {
      final s = q.toLowerCase();
      return m.name.toLowerCase().contains(s) || m.type.toLowerCase().contains(s);
    }).toList(growable: false);

    final stats = _Stats.from(machines);

    return Scaffold(
      appBar: _MachinesHeader(total: stats.total),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        children: [
          _StatsRow(stats: stats),
          const SizedBox(height: 12),
          if (app.lastError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Banner(
                text: app.lastError!,
                color: DT.yellow,
                icon: Icons.warning_amber_rounded,
                onRetry: app.retryLivePipeline,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Banner(
                text: app.isMqttConnected
                    ? 'MQTT connected on ${app.mqttTopic}'
                    : 'Waiting for MQTT connection on ${app.mqttBroker}',
                color: app.isMqttConnected ? DT.green : DT.blue,
                icon: app.isMqttConnected ? Icons.cloud_done_rounded : Icons.cloud_sync_rounded,
                onRetry: app.retryLivePipeline,
              ),
            ),
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
                      hintText: 'Search machines...',
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
          ...filtered.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MachineCard(machine: m),
            ),
          ),
        ],
      ),
    );
  }
}

class _MachinesHeader extends StatelessWidget implements PreferredSizeWidget {
  final int total;
  const _MachinesHeader({required this.total});

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 92,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DT.headerB,
              DT.headerA,
              DT.blue.alphaF(0.12),
            ],
          ),
        ),
      ),
      titleSpacing: 18,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Machines',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Monitor your digital twins • $total total',
            style: TextStyle(color: DT.muted(0.55), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final Future<void> Function() onRetry;

  const _Banner({
    required this.text,
    required this.color,
    required this.icon,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: DT.muted(0.72), fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () {
              onRetry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final _Stats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: '${stats.total}',
            color: DT.muted(0.90),
            bg: DT.surface(0.22),
            border: DT.border(0.45),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Online',
            value: '${stats.online}',
            color: DT.green,
            bg: DT.green.alphaF(0.10),
            border: DT.green.alphaF(0.22),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Warning',
            value: '${stats.warning}',
            color: DT.yellow,
            bg: DT.yellow.alphaF(0.10),
            border: DT.yellow.alphaF(0.22),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Offline',
            value: '${stats.offline}',
            color: DT.red,
            bg: DT.red.alphaF(0.10),
            border: DT.red.alphaF(0.22),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;
  final Color border;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: DT.muted(0.55), fontSize: 12)),
        ],
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;
  const _MachineCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    final ui = _StatusUI.of(machine.status);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.read<AppState>().selectMachine(machine.id),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ui.color.alphaF(0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ui.color.alphaF(0.26)),
                  ),
                  child: Icon(ui.icon, color: ui.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(machine.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(machine.type, style: TextStyle(color: DT.muted(0.55))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: DT.dim(0.55)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Health:', style: TextStyle(color: DT.muted(0.55))),
                const SizedBox(width: 6),
                Text('${machine.efficiency}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                const Spacer(),
                _StatusBadge(text: machine.status.name.toUpperCase(), color: ui.color),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 8,
                color: DT.border(0.30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth * (machine.efficiency.clamp(0, 100) / 100);
                      return Container(
                        width: w,
                        decoration: BoxDecoration(
                          gradient: DT.grad,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: DT.dim(0.50), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(machine.location, style: TextStyle(color: DT.muted(0.45)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.alphaF(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.alphaF(0.26)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusUI {
  final Color color;
  final IconData icon;

  const _StatusUI(this.color, this.icon);

  static _StatusUI of(MachineStatus s) {
    switch (s) {
      case MachineStatus.online:
        return const _StatusUI(DT.green, Icons.check_circle_rounded);
      case MachineStatus.warning:
        return const _StatusUI(DT.yellow, Icons.warning_rounded);
      case MachineStatus.offline:
        return const _StatusUI(DT.red, Icons.cancel_rounded);
      case MachineStatus.maintenance:
        return const _StatusUI(DT.blue, Icons.autorenew_rounded);
    }
  }
}

class _Stats {
  final int total;
  final int online;
  final int warning;
  final int offline;

  const _Stats({
    required this.total,
    required this.online,
    required this.warning,
    required this.offline,
  });

  factory _Stats.from(List<Machine> machines) {
    int count(MachineStatus s) => machines.where((m) => m.status == s).length;
    return _Stats(
      total: machines.length,
      online: count(MachineStatus.online),
      warning: count(MachineStatus.warning),
      offline: count(MachineStatus.offline),
    );
  }
}
