import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/state.dart';
import '../config/live_pipeline_config.dart';
import '../models/machine.dart';
import '../models/telemetry_sample.dart';
import '../theme/dt_colors.dart';
import '../theme/dt_widgets.dart';
import '../widgets/charts.dart';

class DashboardScreen extends StatelessWidget {
  final String? machineId;
  const DashboardScreen({super.key, required this.machineId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final machine = app.selectedMachine;
    final liveSelected = app.isLiveMachine(machine.id);

    if (liveSelected) {
      return _buildLiveDashboard(context, app, machine);
    }

    return _buildStaticDashboard(context, machine);
  }

  Widget _buildLiveDashboard(BuildContext context, AppState app, Machine machine) {
    final tempPoints = _buildChartPoints(app.telemetryHistory, (sample) => sample.temp);
    final pressurePoints = _buildChartPoints(app.telemetryHistory, (sample) => sample.pressure);

    final tempRange = _rangeFor(app.telemetryHistory, (sample) => sample.temp, fallbackMin: 600, fallbackMax: 650);
    final pressureRange = _rangeFor(app.telemetryHistory, (sample) => sample.pressure, fallbackMin: 1550, fallbackMax: 1610);

    final rulValue = app.engineRul > 0 ? app.engineRul.toStringAsFixed(1) : '--';
    final rulDelta = app.isBackendBusy
        ? 'Predicting now'
        : app.lastPredictionAt != null
            ? 'AI updated ${_timeAgo(app.lastPredictionAt)}'
            : 'Needs ${LivePipelineConfig.bufferSize} samples';

    return Scaffold(
      appBar: appHeader(
        title: machine.name,
        subtitle: 'MQTT + backend prediction pipeline',
        leading: _IconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.read<AppState>().backToMachines(),
        ),
        trailing: _LivePill(connected: app.isMqttConnected),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        children: [
          if (app.lastError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: DT.yellow),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        app.lastError!,
                        style: TextStyle(color: DT.muted(0.72), fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        app.retryLivePipeline();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'RUL',
                  value: rulValue,
                  delta: rulDelta,
                  deltaUp: app.lastPredictionAt != null || app.isBackendBusy,
                  icon: Icons.insights_rounded,
                  gradA: DT.blue,
                  gradB: DT.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Buffer',
                  value: '${app.timeSeriesWindow.length}/${LivePipelineConfig.bufferSize}',
                  delta: 'Packets ${app.totalPackets}',
                  deltaUp: app.timeSeriesWindow.length >= LivePipelineConfig.bufferSize,
                  icon: Icons.layers_rounded,
                  gradA: const Color(0xFF22C55E),
                  gradB: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Temp s2',
                  value: '${app.temp.toStringAsFixed(1)}°',
                  delta: app.temp >= LivePipelineConfig.warningTempThreshold ? 'Above threshold' : 'Normal range',
                  deltaUp: app.temp < LivePipelineConfig.warningTempThreshold,
                  icon: Icons.device_thermostat_rounded,
                  gradA: DT.yellow,
                  gradB: const Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Press s3',
                  value: app.pressure.toStringAsFixed(1),
                  delta: 'Speed ${app.speed.toStringAsFixed(1)}',
                  deltaUp: true,
                  icon: Icons.compress_rounded,
                  gradA: DT.purple,
                  gradB: DT.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  title: 'Temperature Trend',
                  subtitle: 'Latest MQTT packets',
                  rightTop: app.hasLiveData ? '${app.temp.toStringAsFixed(1)}°' : '--',
                  rightBottom: 'Current value',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: tempPoints.length < 2
                      ? const _ChartPlaceholder(message: 'Waiting for telemetry data...')
                      : SimpleLineChart(
                          points: tempPoints,
                          minY: tempRange.$1,
                          maxY: tempRange.$2,
                          lineColor: DT.yellow,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  title: 'Pressure Trend',
                  subtitle: 'Latest MQTT packets',
                  rightTop: app.hasLiveData ? app.pressure.toStringAsFixed(1) : '--',
                  rightBottom: 'Current value',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: pressurePoints.length < 2
                      ? const _ChartPlaceholder(message: 'Buffering live packets...')
                      : AreaChart(
                          points: pressurePoints,
                          minY: pressureRange.$1,
                          maxY: pressureRange.$2,
                          lineColor: DT.blue,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Pipeline Status', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _kv('Machine Status', machine.status.name.toUpperCase(), valueColor: _statusColor(machine.status)),
                _kv('MQTT Broker', app.mqttBroker),
                _kv('MQTT Topic', app.mqttTopic),
                _kv('Backend URL', app.backendUrl),
                _kv('Current Cycle', app.currentCycle == 0 ? '--' : '${app.currentCycle}'),
                _kv('Total Messages', '${app.totalPackets}'),
                _kv('Window Ready', app.timeSeriesWindow.length == LivePipelineConfig.bufferSize ? 'YES' : 'NO', valueColor: app.timeSeriesWindow.length == LivePipelineConfig.bufferSize ? DT.green : DT.yellow),
                _kv('Last Packet', _timeAgo(app.lastMessageAt)),
                _kv('Last Prediction', _timeAgo(app.lastPredictionAt)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatusPill(status: machine.status),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        app.isBackendBusy
                            ? 'Sending sliding window to backend...'
                            : 'Latest speed s4: ${app.speed.toStringAsFixed(1)}',
                        style: TextStyle(color: DT.muted(0.50), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticDashboard(BuildContext context, Machine machine) {
    final performance = <DTPoint>[
      const DTPoint('00:00', 85),
      const DTPoint('04:00', 88),
      const DTPoint('08:00', 92),
      const DTPoint('12:00', 89),
      const DTPoint('16:00', 94),
      const DTPoint('20:00', 91),
      const DTPoint('24:00', 93),
    ];

    final temperature = <DTPoint>[
      const DTPoint('00:00', 65),
      const DTPoint('04:00', 68),
      const DTPoint('08:00', 72),
      const DTPoint('12:00', 75),
      const DTPoint('16:00', 73),
      const DTPoint('20:00', 70),
      const DTPoint('24:00', 67),
    ];

    return Scaffold(
      appBar: appHeader(
        title: machine.name,
        subtitle: 'Demo monitoring data',
        leading: _IconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.read<AppState>().backToMachines(),
        ),
        trailing: const _LabelPill(label: 'Demo', color: DT.blue),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Efficiency',
                  value: '${machine.efficiency}%',
                  delta: '+2.3%',
                  deltaUp: true,
                  icon: Icons.speed_rounded,
                  gradA: DT.blue,
                  gradB: DT.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Uptime',
                  value: '98.5%',
                  delta: '+0.8%',
                  deltaUp: true,
                  icon: Icons.show_chart_rounded,
                  gradA: const Color(0xFF22C55E),
                  gradB: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Temp',
                  value: '72°C',
                  delta: '-3°C',
                  deltaUp: false,
                  icon: Icons.device_thermostat_rounded,
                  gradA: DT.yellow,
                  gradB: const Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Power',
                  value: '24.8 kW',
                  delta: '-1.2 kW',
                  deltaUp: false,
                  icon: Icons.bolt_rounded,
                  gradA: DT.purple,
                  gradB: DT.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardHeader(title: 'Performance', subtitle: 'Last 24 hours', rightTop: '93%', rightBottom: 'Average'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: AreaChart(points: performance, minY: 80, maxY: 100, lineColor: DT.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardHeader(title: 'Temperature', subtitle: 'Last 24 hours', rightTop: '70°C', rightBottom: 'Average'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: SimpleLineChart(points: temperature, minY: 60, maxY: 80, lineColor: DT.yellow),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Machine Status', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _kv('Operating Hours', '12,453 hrs'),
                _kv('Cycles Completed', '8,234'),
                _kv('Last Maintenance', '3 days ago'),
                _kv('Next Service', 'In 12 days', valueColor: DT.cyan),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatusPill(status: machine.status),
                    const SizedBox(width: 10),
                    Expanded(child: Text(machine.location, style: TextStyle(color: DT.muted(0.50), fontWeight: FontWeight.w600))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(key, style: TextStyle(color: DT.muted(0.55)))),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

List<DTPoint> _buildChartPoints(
  List<TelemetrySample> history,
  double Function(TelemetrySample sample) selector,
) {
  return history.map((sample) {
    final label = sample.cycle > 0 ? 'C${sample.cycle}' : '${sample.receivedAt.second}s';
    return DTPoint(label, selector(sample));
  }).toList(growable: false);
}

(double, double) _rangeFor(
  List<TelemetrySample> history,
  double Function(TelemetrySample sample) selector, {
  required double fallbackMin,
  required double fallbackMax,
}) {
  if (history.isEmpty) {
    return (fallbackMin, fallbackMax);
  }

  var min = selector(history.first);
  var max = min;

  for (final sample in history.skip(1)) {
    final value = selector(sample);
    if (value < min) min = value;
    if (value > max) max = value;
  }

  if (min == max) {
    return (min - 1, max + 1);
  }

  final padding = (max - min) * 0.15;
  return (min - padding, max + padding);
}

String _timeAgo(DateTime? time) {
  if (time == null) {
    return '--';
  }

  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 10) return 'just now';
  if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  return '${diff.inHours}h ago';
}

Color _statusColor(MachineStatus status) {
  switch (status) {
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

class _ChartPlaceholder extends StatelessWidget {
  final String message;
  const _ChartPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: DT.muted(0.55), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DT.headerA.alphaF(0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DT.border(0.55)),
        ),
        child: Icon(icon, color: DT.muted(0.65), size: 20),
      ),
    );
  }
}

class _LivePill extends StatefulWidget {
  final bool connected;
  const _LivePill({required this.connected});

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.connected ? DT.green : DT.red;
    final label = widget.connected ? 'Live' : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.alphaF(0.16),
        border: Border.all(color: color.alphaF(0.28)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: c,
            builder: (_, __) => Opacity(
              opacity: widget.connected ? 0.35 + (c.value * 0.65) : 1,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}


class _LabelPill extends StatelessWidget {
  final String label;
  final Color color;
  const _LabelPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.alphaF(0.16),
        border: Border.all(color: color.alphaF(0.28)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String delta;
  final bool deltaUp;
  final IconData icon;
  final Color gradA;
  final Color gradB;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.deltaUp,
    required this.icon,
    required this.gradA,
    required this.gradB,
  });

  @override
  Widget build(BuildContext context) {
    final arrow = deltaUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final dColor = deltaUp ? DT.green : DT.yellow;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradA.alphaF(0.12), gradB.alphaF(0.10)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gradA.alphaF(0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: gradA.alphaF(0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: gradA.alphaF(0.26)),
                    ),
                    child: Icon(icon, color: gradA, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(color: DT.muted(0.70), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(arrow, color: dColor, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      delta,
                      style: TextStyle(color: dColor, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rightTop;
  final String rightBottom;

  const _CardHeader({
    required this.title,
    required this.subtitle,
    required this.rightTop,
    required this.rightBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: DT.muted(0.55))),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(rightTop, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(rightBottom, style: TextStyle(color: DT.muted(0.55))),
        ]),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final MachineStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final ui = _StatusUI.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ui.color.alphaF(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ui.color.alphaF(0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ui.icon, color: ui.color, size: 16),
          const SizedBox(width: 6),
          Text(status.name.toUpperCase(), style: TextStyle(color: ui.color, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
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
