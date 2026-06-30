import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const String broker =
      'd566266c1ba14ed2aa4c2b5b823596a2.s1.eu.hivemq.cloud';
  static const int port = 8883;
  static const String username = 'Fortlock';
  static const String password = 'Fortlock1';

  static const String clientIdPrefix = 'fortlock_app_';

  static const String topicStatus = 'smart_home/status';
  static const String topicControl = 'smart_home/control';
  static const String topicAlarm = 'smart_home/alarm';
  static const String topicAccess = 'smart_home/access';
  static const String topicRegister = 'smart_home/register';

  MqttServerClient? _client;

  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final _accessController = StreamController<Map<String, dynamic>>.broadcast();
  final _alarmController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get accessStream => _accessController.stream;
  Stream<Map<String, dynamic>> get alarmStream => _alarmController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    _errorController.add('Memulai koneksi ke $broker:$port...');
    final clientId =
        '$clientIdPrefix${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient.withPort(broker, clientId, port);
    _client!.secure = true;
    _client!.securityContext = SecurityContext(withTrustedRoots: true);
    _client!.onBadCertificate = (dynamic certificate) => true;
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = false;
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.logging(on: true);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;

    try {
      _errorController.add('Menjalankan connect()...');
      await _client!.connect(username, password).timeout(const Duration(seconds: 15));
      _errorController.add('connect() selesai tanpa exception.');
    } catch (e) {
      _connectionController.add(false);
      _errorController.add('EXCEPTION: ${e.toString()}');
      _client?.disconnect();
      return;
    }

    final state = _client!.connectionStatus?.state;
    final returnCode = _client!.connectionStatus?.returnCode;
    _errorController.add('State setelah connect: $state, returnCode: $returnCode');

    if (state == MqttConnectionState.connected) {
      _connectionController.add(true);
      _errorController.add('Berhasil terhubung! Subscribing...');
      _subscribeAll();
    } else {
      _connectionController.add(false);
      _errorController.add('Gagal: state=$state, returnCode=$returnCode');
    }
  }

  void _onConnected() => _connectionController.add(true);
  void _onDisconnected() => _connectionController.add(false);

  void _subscribeAll() {
    _client!.subscribe(topicStatus, MqttQos.atLeastOnce);
    _client!.subscribe(topicAccess, MqttQos.atLeastOnce);
    _client!.subscribe(topicAlarm, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> events) {
      final recMess = events[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);
      final topic = events[0].topic;

      if (topic == topicStatus) {
        _statusController.add(_parsePayload(payload));
      } else if (topic == topicAccess) {
        _accessController.add(_parsePayload(payload));
      } else if (topic == topicAlarm) {
        _alarmController.add(_parsePayload(payload));
      }
    });
  }

  Map<String, dynamic> _parsePayload(String payload) {
    final map = <String, dynamic>{};
    for (final pair in payload.split(';')) {
      final kv = pair.split('=');
      if (kv.length == 2) {
        map[kv[0].trim()] = kv[1].trim();
      }
    }
    if (map.isEmpty) {
      map['raw'] = payload;
    }
    return map;
  }

  void publish(String topic, String message) {
    if (!isConnected) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void lockDoor() => publish(topicControl, 'LOCK');
  void unlockDoor() => publish(topicControl, 'UNLOCK');
  void alarmOn() => publish(topicControl, 'ALARM_ON');
  void alarmOff() => publish(topicControl, 'ALARM_OFF');
  void triggerPanic() => publish(topicControl, 'PANIC');

  void registerRfid(String rfidUid) => publish(topicRegister, rfidUid);

  void disconnect() => _client?.disconnect();

  void dispose() {
    _statusController.close();
    _accessController.close();
    _alarmController.close();
    _connectionController.close();
    _errorController.close();
    _client?.disconnect();
  }
}
