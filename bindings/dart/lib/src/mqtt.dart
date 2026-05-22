// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// MQTT 3.1.1+ protocol bindings for proven-servers.
///
/// Mirrors the Idris2 modules `MQTT.QoS` and `MQTT.PacketType`.
/// Discriminant values are the MQTT 3.1.1 wire values.
///
/// See `protocols/proven-mqtt/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// MQTT Constants
// ---------------------------------------------------------------------------

/// Standard MQTT port.
const int mqttPort = 1883;

/// MQTT over TLS port.
const int mqttsPort = 8883;

// ---------------------------------------------------------------------------
// QoS (MQTT 3.1.1 Section 4.3)
// ---------------------------------------------------------------------------

/// MQTT Quality of Service levels.
///
/// Discriminant values are the 2-bit QoS wire codes.
enum MqttQoS {
  /// QoS 0: At most once delivery (fire and forget).
  atMostOnce(0),

  /// QoS 1: At least once delivery (PUBACK required).
  atLeastOnce(1),

  /// QoS 2: Exactly once delivery (PUBREC/PUBREL/PUBCOMP handshake).
  exactlyOnce(2);

  final int code;
  const MqttQoS(this.code);

  /// Decode from a 2-bit numeric code.
  ///
  /// Returns `null` for the reserved value 3 and invalid input.
  static MqttQoS? fromCode(int code) {
    if (code >= 0 && code < values.length) return values[code];
    return null;
  }

  /// Whether this QoS level requires acknowledgement.
  bool get requiresAck => this != atMostOnce;

  /// Number of ack packets needed for this QoS flow.
  ///
  /// QoS 0: 0, QoS 1: 1, QoS 2: 3.
  int get ackPacketCount {
    switch (this) {
      case atMostOnce:
        return 0;
      case atLeastOnce:
        return 1;
      case exactlyOnce:
        return 3;
    }
  }
}

// ---------------------------------------------------------------------------
// PacketType (MQTT 3.1.1 Section 2.2)
// ---------------------------------------------------------------------------

/// MQTT control packet types.
///
/// Values are the 4-bit wire codes.
enum MqttPacketType {
  connect(1),
  connack(2),
  publish(3),
  puback(4),
  pubrec(5),
  pubrel(6),
  pubcomp(7),
  subscribe(8),
  suback(9),
  unsubscribe(10),
  unsuback(11),
  pingreq(12),
  pingresp(13),
  disconnect(14);

  final int wireCode;
  const MqttPacketType(this.wireCode);

  /// Decode from a 4-bit wire code.
  static MqttPacketType? fromWireCode(int code) {
    for (final pt in MqttPacketType.values) {
      if (pt.wireCode == code) return pt;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// ConnectReturnCode (MQTT 3.1.1 Section 3.2.2.3)
// ---------------------------------------------------------------------------

/// CONNACK return codes.
enum MqttConnectReturnCode {
  accepted(0),
  unacceptableVersion(1),
  identifierRejected(2),
  serverUnavailable(3),
  badCredentials(4),
  notAuthorized(5);

  final int code;
  const MqttConnectReturnCode(this.code);

  static MqttConnectReturnCode? fromCode(int code) {
    if (code >= 0 && code < values.length) return values[code];
    return null;
  }
}

// ---------------------------------------------------------------------------
// MqttContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// An MQTT context slot in the Zig FFI pool.
///
/// Wraps the `mqtt_*` C functions with automatic resource cleanup.
class MqttContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('mqtt_destroy_context');
  late final _getPacketType = _ffi.lookupGetTag('mqtt_get_packet_type');
  late final _setQos = _ffi.lookupSetTag('mqtt_set_qos');

  MqttContext._(this._ffi, this._slot);

  /// Create a new MQTT context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory MqttContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('mqtt_create_context');
    final slot = ProvenError.checkSlot(create());
    return MqttContext._(ffi, slot);
  }

  /// Release the context slot back to the pool.
  void dispose() {
    if (!_disposed) {
      _destroy(_slot);
      _disposed = true;
    }
  }

  void _checkDisposed() {
    if (_disposed) throw const ProvenError('context already disposed');
  }

  /// Get the parsed packet type.
  MqttPacketType? getPacketType() {
    _checkDisposed();
    return MqttPacketType.fromWireCode(_getPacketType(_slot));
  }

  /// Set the QoS level for subsequent operations.
  ///
  /// Throws [ProvenError] on invalid parameter.
  void setQoS(MqttQoS qos) {
    _checkDisposed();
    ProvenError.checkParamStatus(_setQos(_slot, qos.code));
  }
}
