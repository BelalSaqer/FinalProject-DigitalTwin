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