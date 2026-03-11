import '../config/live_pipeline_config.dart';
import '../models/machine.dart';

const List<Machine> baseMachines = <Machine>[
  Machine(
    id: LivePipelineConfig.liveMachineId,
    name: 'Engine 1 Digital Twin',
    type: 'Aircraft Engine',
    status: MachineStatus.offline,
    efficiency: 0,
    location: 'MQTT Live Stream',
  ),
  Machine(
    id: '2',
    name: 'Robotic Arm B2',
    type: 'Industrial Robot',
    status: MachineStatus.online,
    efficiency: 98,
    location: 'Floor 1 - Bay B',
  ),
  Machine(
    id: '3',
    name: 'Press Machine C1',
    type: 'Hydraulic Press',
    status: MachineStatus.warning,
    efficiency: 76,
    location: 'Floor 2 - Bay A',
  ),
  Machine(
    id: '4',
    name: 'Conveyor System D3',
    type: 'Belt Conveyor',
    status: MachineStatus.online,
    efficiency: 91,
    location: 'Floor 2 - Bay C',
  ),
  Machine(
    id: '5',
    name: 'Lathe Machine E1',
    type: 'CNC Lathe',
    status: MachineStatus.maintenance,
    efficiency: 0,
    location: 'Floor 1 - Bay C',
  ),
  Machine(
    id: '6',
    name: 'Welding Robot F2',
    type: 'Spot Welder',
    status: MachineStatus.online,
    efficiency: 89,
    location: 'Floor 3 - Bay A',
  ),
  Machine(
    id: '7',
    name: 'Assembly Line G4',
    type: 'Automated Assembly',
    status: MachineStatus.offline,
    efficiency: 0,
    location: 'Floor 3 - Bay B',
  ),
  Machine(
    id: '8',
    name: 'Packaging Unit H1',
    type: 'Auto Packager',
    status: MachineStatus.online,
    efficiency: 96,
    location: 'Floor 3 - Bay C',
  ),
];
