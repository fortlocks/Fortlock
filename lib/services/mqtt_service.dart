import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const String broker = 'broker.hivemq.com';
  static const int port = 1883;
  static const String clientIdPrefix = 'fortlock_app_';

  static const String topicStatus = 'fortlock/smart_home/status';
  static const String topicControl = 'fortlock/smart_home/control';
  static const String topicRegister = 'fortlock/smart_home/register';
  static const String topicPanic = 'fortlock/smart_home/panic';
  static const String topicAccessLog = 'fortlock/smart_home/access_log';

  MqttServerClient? _client;

  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final _accessLogController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get accessLogStream =>
      _accessLogController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    final clientId =
        '$clientIdPrefix${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(broker, clientId);
    _client!.port = port;
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      _connectionController.add(false);
      _client?.disconnect();
      return;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      _subscribeAll();
    } else {
      _connectionController.add(false);
    }
  }

  void _onConnected() {
    _connectionController.add(true);
  }

  void _onDisconnected() {
    _connectionController.add(false);
  }

  void _subscribeAll() {
    _client!.subscribe(topicStatus, MqttQos.atLeastOnce);
    _client!.subscribe(topicAccessLog, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> events) {
      final recMess = events[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);
      final topic = events[0].topic;

      if (topic == topicStatus) {
        _statusController.add(_parsePayload(payload));
      } else if (topic == topicAccessLog) {
        _accessLogController.add(_parsePayload(payload));
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
  void triggerAlarmOff() => publish(topicControl, 'ALARM_OFF');
  void triggerPanic() => publish(topicPanic, 'PANIC_ON');
  void cancelPanic() => publish(topicPanic, 'PANIC_OFF');
  void registerGuestRfid(String rfidUid) =>
      publish(topicRegister, rfidUid);
  void revokeGuestRfid(String rfidUid) =>
      publish(topicControl, 'REVOKE_$rfidUid');

  void disconnect() {
    _client?.disconnect();
  }

  void dispose() {
    _statusController.close();
    _accessLogController.close();
    _connectionController.close();
    _client?.disconnect();
  }
}
