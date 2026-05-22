// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
enum MessageType {
  discover(0),
  offer(1),
  request(2),
  ack(3),
  nak(4),
  release(5),
  inform(6),
  decline(7);

  const MessageType(this.tag);
  final int tag;

  static MessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// OptionCode matching the Idris2 ABI tags.
enum OptionCode {
  subnetMask(0),
  router(1),
  dns(2),
  domainName(3),
  leaseTime(4),
  serverId(5),
  requestedIp(6),
  msgType(7);

  const OptionCode(this.tag);
  final int tag;

  static OptionCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HardwareType matching the Idris2 ABI tags.
enum HardwareType {
  ethernet(0),
  ieee802(1),
  arcnet(2),
  frameRelay(3);

  const HardwareType(this.tag);
  final int tag;

  static HardwareType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DhcpState matching the Idris2 ABI tags.
enum DhcpState {
  idle(0),
  discoverReceived(1),
  offerSent(2),
  requestReceived(3),
  ackSent(4),
  nakSent(5);

  const DhcpState(this.tag);
  final int tag;

  static DhcpState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LeaseState matching the Idris2 ABI tags.
enum LeaseState {
  available(0),
  offered(1),
  bound(2),
  renewing(3),
  rebinding(4),
  expired(5);

  const LeaseState(this.tag);
  final int tag;

  static LeaseState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RelaySubOption matching the Idris2 ABI tags.
enum RelaySubOption {
  circuitId(0),
  remoteId(1);

  const RelaySubOption(this.tag);
  final int tag;

  static RelaySubOption? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
