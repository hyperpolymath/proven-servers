// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OSPF protocol types for proven-servers.

/// PacketType matching the Idris2 ABI tags.
enum PacketType {
  hello(0),
  databaseDescription(1),
  linkStateRequest(2),
  linkStateUpdate(3),
  linkStateAck(4);

  const PacketType(this.tag);
  final int tag;

  static PacketType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NeighborState matching the Idris2 ABI tags.
enum NeighborState {
  down(0),
  attempt(1),
  init(2),
  twoWay(3),
  exStart(4),
  exchange(5),
  loading(6),
  full(7);

  const NeighborState(this.tag);
  final int tag;

  static NeighborState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LsaType matching the Idris2 ABI tags.
enum LsaType {
  routerLsa(0),
  networkLsa(1),
  summaryLsa(2),
  asbrSummaryLsa(3),
  asExternalLsa(4);

  const LsaType(this.tag);
  final int tag;

  static LsaType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AreaType matching the Idris2 ABI tags.
enum AreaType {
  normal(0),
  stub(1),
  totallyStub(2),
  nssa(3);

  const AreaType(this.tag);
  final int tag;

  static AreaType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// OspfError matching the Idris2 ABI tags.
enum OspfError {
  ok(0),
  invalidSlot(1),
  notActive(2),
  invalidTransition(3),
  invalidPacket(4),
  areaError(5),
  floodLimit(6);

  const OspfError(this.tag);
  final int tag;

  static OspfError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
