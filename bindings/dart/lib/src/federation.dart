// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Federation protocol types for proven-servers.

/// ActivityType matching the Idris2 ABI tags.
enum ActivityType {
  create(0),
  update(1),
  delete(2),
  follow(3),
  accept(4),
  reject(5),
  announce(6),
  like(7),
  undo(8),
  block(9),
  flag(10);

  const ActivityType(this.tag);
  final int tag;

  static ActivityType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ActorType matching the Idris2 ABI tags.
enum ActorType {
  person(0),
  service(1),
  application(2),
  group(3),
  organization(4);

  const ActorType(this.tag);
  final int tag;

  static ActorType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DeliveryStatus matching the Idris2 ABI tags.
enum DeliveryStatus {
  pending(0),
  delivered(1),
  failed(2),
  rejected(3),
  deferred_(4);

  const DeliveryStatus(this.tag);
  final int tag;

  static DeliveryStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TrustLevel matching the Idris2 ABI tags.
enum TrustLevel {
  selfSigned(0),
  peerVerified(1),
  federationTrusted(2),
  revoked(3),
  unknown(4);

  const TrustLevel(this.tag);
  final int tag;

  static TrustLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ObjectType matching the Idris2 ABI tags.
enum ObjectType {
  note(0),
  article(1),
  image(2),
  video(3),
  audio(4),
  document(5),
  event(6),
  collection(7),
  orderedCollection(8);

  const ObjectType(this.tag);
  final int tag;

  static ObjectType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  active(1),
  processing(2),
  delivering(3),
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
