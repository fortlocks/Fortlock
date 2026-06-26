class SystemStatus {
  final String pintu;
  final String kunci;
  final String alarm;
  final String esp32;
  final String mode;
  final DateTime? lastUpdate;

  SystemStatus({
    this.pintu = 'closed',
    this.kunci = 'locked',
    this.alarm = 'off',
    this.esp32 = 'offline',
    this.mode = 'normal',
    this.lastUpdate,
  });

  factory SystemStatus.fromMap(Map<dynamic, dynamic> map) {
    return SystemStatus(
      pintu: map['pintu'] ?? 'closed',
      kunci: map['kunci'] ?? 'locked',
      alarm: map['alarm'] ?? 'off',
      esp32: map['esp32'] ?? 'offline',
      mode: map['mode'] ?? 'normal',
      lastUpdate: map['last_update'] != null
          ? DateTime.tryParse(map['last_update'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pintu': pintu,
      'kunci': kunci,
      'alarm': alarm,
      'esp32': esp32,
      'mode': mode,
      'last_update': lastUpdate?.toIso8601String(),
    };
  }

  bool get isOnline => esp32 == 'online';
  bool get isLocked => kunci == 'locked';
  bool get isDoorOpen => pintu == 'open';
  bool get isAlarmOn => alarm == 'on';
  bool get isPanicMode => mode == 'panic';

  SystemStatus copyWith({
    String? pintu,
    String? kunci,
    String? alarm,
    String? esp32,
    String? mode,
    DateTime? lastUpdate,
  }) {
    return SystemStatus(
      pintu: pintu ?? this.pintu,
      kunci: kunci ?? this.kunci,
      alarm: alarm ?? this.alarm,
      esp32: esp32 ?? this.esp32,
      mode: mode ?? this.mode,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
