// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// AMQP protocol types for proven-servers.

/// FrameType matching the Idris2 ABI tags.
enum FrameType {
  method(0),
  header(1),
  body(2),
  heartbeat(3);

  const FrameType(this.tag);
  final int tag;

  static FrameType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MethodClass matching the Idris2 ABI tags.
enum MethodClass {
  connection(0),
  channel(1),
  exchange(2),
  queue(3),
  basic(4),
  tx(5),
  confirm(6);

  const MethodClass(this.tag);
  final int tag;

  static MethodClass? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ExchangeType matching the Idris2 ABI tags.
enum ExchangeType {
  direct(0),
  fanout(1),
  topic(2),
  headers(3);

  const ExchangeType(this.tag);
  final int tag;

  static ExchangeType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DeliveryMode matching the Idris2 ABI tags.
enum DeliveryMode {
  nonPersistent(0),
  persistent(1);

  const DeliveryMode(this.tag);
  final int tag;

  static DeliveryMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorSeverity matching the Idris2 ABI tags.
enum ErrorSeverity {
  channelLevel(0),
  connectionLevel(1);

  const ErrorSeverity(this.tag);
  final int tag;

  static ErrorSeverity? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ConnectionState matching the Idris2 ABI tags.
enum ConnectionState {
  connectionState_Idle(0),
  negotiating(1),
  tuningOk(2),
  open(3),
  closing(4);

  const ConnectionState(this.tag);
  final int tag;

  static ConnectionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ChannelState matching the Idris2 ABI tags.
enum ChannelState {
  closed(0),
  opening(1),
  chOpen(2),
  chClosing(3);

  const ChannelState(this.tag);
  final int tag;

  static ChannelState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BrokerState matching the Idris2 ABI tags.
enum BrokerState {
  brokerState_Idle(0),
  connected(1),
  channelOpen(2),
  consuming(3),
  publishing(4),
  disconnecting(5);

  const BrokerState(this.tag);
  final int tag;

  static BrokerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
