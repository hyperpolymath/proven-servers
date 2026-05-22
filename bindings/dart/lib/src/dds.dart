// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DDS protocol types for proven-servers.

/// ReliabilityKind matching the Idris2 ABI tags.
enum ReliabilityKind {
  bestEffort(0),
  reliable(1);

  const ReliabilityKind(this.tag);
  final int tag;

  static ReliabilityKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DurabilityKind matching the Idris2 ABI tags.
enum DurabilityKind {
  transientLocal(1),
  transient(2),
  persistent(3);

  const DurabilityKind(this.tag);
  final int tag;

  static DurabilityKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HistoryKind matching the Idris2 ABI tags.
enum HistoryKind {
  keepLast(0),
  keepAll(1);

  const HistoryKind(this.tag);
  final int tag;

  static HistoryKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// OwnershipKind matching the Idris2 ABI tags.
enum OwnershipKind {
  shared(0),
  exclusive(1);

  const OwnershipKind(this.tag);
  final int tag;

  static OwnershipKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EntityType matching the Idris2 ABI tags.
enum EntityType {
  participant(0),
  publisher(1),
  subscriber(2),
  topic(3),
  dataWriter(4),
  dataReader(5);

  const EntityType(this.tag);
  final int tag;

  static EntityType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ParticipantState matching the Idris2 ABI tags.
enum ParticipantState {
  idle(0),
  joined(1),
  publishing(2),
  subscribing(3),
  leaving(4);

  const ParticipantState(this.tag);
  final int tag;

  static ParticipantState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
