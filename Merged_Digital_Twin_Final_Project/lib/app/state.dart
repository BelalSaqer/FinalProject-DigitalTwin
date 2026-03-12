import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../config/live_pipeline_config.dart';
import '../data/machine_catalog.dart';
import '../models/machine.dart';
import '../models/telemetry_sample.dart';

enum AppTab { machines, dashboard, alerts, history, reports, profile }

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AppTab _currentTab = AppTab.machines;
  AppTab get currentTab => _currentTab;

  String? _selectedMachineId;
  String? get selectedMachineId => _selectedMachineId;

  MqttServerClient? _mqttClient;
  StreamSubscription<dynamic>? _mqttSubscription;
  bool _mqttConnected = false;
  bool get isMqttConnected => _mqttConnected;

  bool _backendBusy = false;
  bool get isBackendBusy => _backendBusy;

  int _totalPackets = 0;
  int get totalPackets => _totalPackets;

  double _temp = 0;
  double get temp => _temp;

  double _pressure = 0;
  double get pressure => _pressure;

  double _speed = 0;
  double get speed => _speed;

  double _engineRul = 0;
  double get engineRul => _engineRul;

  DateTime? _lastMessageAt;
  DateTime? get lastMessageAt => _lastMessageAt;

  DateTime? _lastPredictionAt;
  DateTime? get lastPredictionAt => _lastPredictionAt;

  String? _lastError;
  String? get lastError => _lastError;

  final List<TelemetrySample> _telemetryHistory = <TelemetrySample>[];
  List<TelemetrySample> get telemetryHistory => List<TelemetrySample>.unmodifiable(_telemetryHistory);

  final List<List<double>> _timeSeriesBuffer = <List<double>>[];
  List<List<double>> get timeSeriesWindow => List<List<double>>.unmodifiable(_timeSeriesBuffer);

  bool _disposed = false;

  List<Machine> get machines {
    return baseMachines.map((machine) {
      if (machine.id != LivePipelineConfig.liveMachineId) {
        return machine;
      }

      return Machine(
        id: machine.id,
        name: machine.name,
        type: machine.type,
        status: liveMachineStatus,
        efficiency: liveHealthScore,
        location: hasLiveData ? 'Cycle $currentCycle • MQTT Stream' : machine.location,
      );
    }).toList(growable: false);
  }

  Machine get selectedMachine {
    final wanted = _selectedMachineId ?? LivePipelineConfig.liveMachineId;
    for (final machine in machines) {
      if (machine.id == wanted) {
        return machine;
      }
    }
    return machines.first;
  }

  bool get hasLiveData => _telemetryHistory.isNotEmpty;

  int get liveHealthScore {
    if (_engineRul <= 0) return 0;
    final score = (_engineRul / LivePipelineConfig.maxRul) * 100;
    return score.clamp(0, 100).round();
  }

  MachineStatus get liveMachineStatus {
    if (!_mqttConnected) return MachineStatus.offline;
    if (!hasLiveData) return MachineStatus.maintenance;
    if (_engineRul > 0 && _engineRul <= LivePipelineConfig.warningRulThreshold) return MachineStatus.warning;
    if (_temp >= LivePipelineConfig.warningTempThreshold) return MachineStatus.warning;
    return MachineStatus.online;
  }

  bool isLiveMachine(String? id) => id == LivePipelineConfig.liveMachineId;

  String get mqttTopic => LivePipelineConfig.mqttTopic;
  String get mqttBroker => LivePipelineConfig.mqttBroker;
  String get backendUrl => LivePipelineConfig.backendUrl;

  int get currentCycle => _telemetryHistory.isNotEmpty ? _telemetryHistory.last.cycle : 0;

  void login() {
    _isLoggedIn = true;
    _currentTab = AppTab.machines;
    _selectedMachineId = null;
    _safeNotify();
    unawaited(startLivePipeline());
  }

  void logout() {
    _isLoggedIn = false;
    _currentTab = AppTab.machines;
    _selectedMachineId = null;
    _disconnectMqtt();
    _resetLiveState();
    _safeNotify();
  }

  void setTab(AppTab tab) {
    _currentTab = tab;
    _safeNotify();
  }

  void selectMachine(String id) {
    _selectedMachineId = id;
    _currentTab = AppTab.dashboard;
    _safeNotify();
  }

  void backToMachines() {
    _currentTab = AppTab.machines;
    _safeNotify();
  }

  Future<void> startLivePipeline() async {
    if (_mqttClient != null) return;
    await _connectMqtt();
  }

  Future<void> retryLivePipeline() async {
    _disconnectMqtt();
    await _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    final clientId = 'final_project_${DateTime.now().millisecondsSinceEpoch}';
    final mqttClient = MqttServerClient(LivePipelineConfig.mqttBroker, clientId);
    mqttClient.port = LivePipelineConfig.mqttPort;
    mqttClient.keepAlivePeriod = 20;
    mqttClient.onConnected = _onConnected;
    mqttClient.onDisconnected = _onDisconnected;

    _mqttClient = mqttClient;

    try {
      await mqttClient.connect();
      if (mqttClient.connectionStatus?.state != MqttConnectionState.connected) {
        _mqttConnected = false;
        _lastError = 'Unable to connect to MQTT broker.';
        mqttClient.disconnect();
        _mqttClient = null;
        _safeNotify();
        return;
      }
      _lastError = null;
      _safeNotify();
    } catch (e) {
      _mqttConnected = false;
      _lastError = 'MQTT connection error: $e';
      try { mqttClient.disconnect(); } catch (_) {}
      _mqttClient = null;
      _safeNotify();
    }
  }

  void _onConnected() {
    _mqttConnected = true;
    _lastError = null;

    final client = _mqttClient;
    if (client != null) {
      client.subscribe(LivePipelineConfig.mqttTopic, MqttQos.atMostOnce);
      _mqttSubscription?.cancel();
      _mqttSubscription = client.updates?.listen(_handleBrokerUpdate);
    }
    _safeNotify();
  }

  void _onDisconnected() {
    _mqttConnected = false;
    _safeNotify();
  }

  void _handleBrokerUpdate(dynamic events) {
    if (events == null || events.isEmpty) return;
    try {
      final MqttPublishMessage recMess = events[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _handlePayload(payload);
    } catch (e) {
      _lastError = 'Payload decode error: $e';
      _safeNotify();
    }
  }

  void _handlePayload(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload) as Map<String, dynamic>;
      final sample = TelemetrySample.fromPayload(data); // ✅ engineId موجود

      _totalPackets += 1;
      _temp = sample.temp;
      _pressure = sample.pressure;
      _speed = sample.speed;
      _lastMessageAt = sample.receivedAt;
      _lastError = null;

      if (_telemetryHistory.length >= LivePipelineConfig.chartHistorySize) _telemetryHistory.removeAt(0);
      _telemetryHistory.add(sample);

      if (_timeSeriesBuffer.length >= LivePipelineConfig.bufferSize) _timeSeriesBuffer.removeAt(0);
      _timeSeriesBuffer.add(sample.toFeatureVector());

      _safeNotify();

      if (_timeSeriesBuffer.length == LivePipelineConfig.bufferSize) {
        unawaited(_sendToBackend(_cloneWindow()));
      }
    } catch (e) {
      _lastError = 'Payload parse error: $e';
      _safeNotify();
    }
  }

  List<List<double>> _cloneWindow() {
    return _timeSeriesBuffer.map((row) => List<double>.from(row)).toList(growable: false);
  }

 Future<void> _sendToBackend(List<List<double>> seriesData) async {
  if (_backendBusy) return;
  _backendBusy = true;
  _safeNotify();

  print("📡 Sending request to: ${LivePipelineConfig.backendUrl}");
  print("📊 Data Sample (First Row): ${seriesData.first}");

  try {
    final response = await http.post(
      Uri.parse(LivePipelineConfig.backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'series_data': seriesData}),
    ).timeout(const Duration(seconds: 8));

    print("📥 Status Code: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      _engineRul = _asResponseDouble(result['prediction']);
      print("✅ RUL Updated: $_engineRul");
      _lastPredictionAt = DateTime.now();
      _lastError = null;
    } else {
      _lastError = 'Backend error ${response.statusCode}';
    }
  } catch (e) {
    print("❌ HTTP Error: $e");
    _lastError = 'Backend request failed: $e';
  } finally {
    _backendBusy = false;
    _safeNotify();
  }
}

  void _disconnectMqtt() {
    _mqttSubscription?.cancel();
    _mqttSubscription = null;

    final client = _mqttClient;
    _mqttClient = null;

    try { client?.disconnect(); } catch (_) {}
    _mqttConnected = false;
  }

  void _resetLiveState() {
    _backendBusy = false;
    _totalPackets = 0;
    _temp = 0;
    _pressure = 0;
    _speed = 0;
    _engineRul = 0;
    _lastMessageAt = null;
    _lastPredictionAt = null;
    _lastError = null;
    _telemetryHistory.clear();
    _timeSeriesBuffer.clear();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _disconnectMqtt();
    super.dispose();
  }
}

double _asResponseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0.0;
}