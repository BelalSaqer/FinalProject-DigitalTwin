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