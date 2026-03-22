// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Git protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
enum Command {
  uploadPack(0),
  receivePack(1),
  uploadArchive(2);

  const Command(this.tag);
  final int tag;

  static Command? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PacketType matching the Idris2 ABI tags.
enum PacketType {
  flush(0),
  delimiter(1),
  responseEnd(2),
  data(3),
  pktError(4),
  sidebandData(5),
  sidebandProgress(6),
  sidebandError(7);

  const PacketType(this.tag);
  final int tag;

  static PacketType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RefType matching the Idris2 ABI tags.
enum RefType {
  branch(0),
  tag(1),
  head(2),
  remote(3),
  gitNote(4);

  const RefType(this.tag);
  final int tag;

  static RefType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Capability matching the Idris2 ABI tags.
enum Capability {
  multiAck(0),
  thinPack(1),
  sideBand64k(2),
  ofsDelta(3),
  shallow(4),
  deepenSince(5),
  deepenNot(6),
  filterSpec(7),
  objectFormat(8);

  const Capability(this.tag);
  final int tag;

  static Capability? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HookResult matching the Idris2 ABI tags.
enum HookResult {
  accept(0),
  reject(1);

  const HookResult(this.tag);
  final int tag;

  static HookResult? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  discovery(1),
  negotiating(2),
  transfer(3),
  shutdown(4);

  const ServerState(this.tag);
  final int tag;

  static ServerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
