enum MachineStatus { online, warning, offline, maintenance }

class Machine {
  final String id;
  final String name;
  final String type;
  final MachineStatus status;
  final int efficiency;
  final String location;

  const Machine({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.efficiency,
    required this.location,
  });
}