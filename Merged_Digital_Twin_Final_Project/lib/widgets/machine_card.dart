import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/machine.dart';
import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';
import '../app/state.dart';

class MachineCard extends StatelessWidget {
  final Machine machine;
  const MachineCard({super.key, required this.machine});

  IconData _icon(MachineStatus s) {
    switch (s) {
      case MachineStatus.online:
        return Icons.check_circle_rounded;
      case MachineStatus.warning:
        return Icons.warning_rounded;
      case MachineStatus.offline:
        return Icons.cancel_rounded;
      case MachineStatus.maintenance:
        return Icons.bolt_rounded;
    }
  }

  Color _color(MachineStatus s) {
    switch (s) {
      case MachineStatus.online:
        return DT.green;
      case MachineStatus.warning:
        return DT.yellow;
      case MachineStatus.offline:
        return DT.red;
      case MachineStatus.maintenance:
        return DT.blue;
    }
  }

  String _label(MachineStatus s) {
    switch (s) {
      case MachineStatus.online:
        return 'online';
      case MachineStatus.warning:
        return 'warning';
      case MachineStatus.offline:
        return 'offline';
      case MachineStatus.maintenance:
        return 'maintenance';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(machine.status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.read<AppState>().selectMachine(machine.id),
      child: GlassCard(
        radius: 18,        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon(machine.status), color: c, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(machine.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(machine.type, style: TextStyle(color: DT.muted(0.55))),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: DT.dim(0.45)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        Text('Efficiency: ', style: TextStyle(color: DT.muted(0.55))),
                        Text('${machine.efficiency}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 6,
                        color: DT.border(0.50),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (machine.efficiency.clamp(0, 100)) / 100.0,
                            child: Container(decoration: const BoxDecoration(gradient: DT.grad)),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                _StatusBadge(text: _label(machine.status), color: c),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(color: DT.dim(0.35), shape: BoxShape.circle)),
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
        color: color.alphaF(0.16),
        border: Border.all(color: color.alphaF(0.28)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.w700),
      ),
    );
  }
}