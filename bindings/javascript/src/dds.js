// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// DDS protocol types for proven-servers.

/** ReliabilityKind matching the Idris2 ABI tags. */
export const ReliabilityKind = Object.freeze({
  BEST_EFFORT: 0,
  RELIABLE: 1,
});

/** DurabilityKind matching the Idris2 ABI tags. */
export const DurabilityKind = Object.freeze({
  TRANSIENT_LOCAL: 1,
  TRANSIENT: 2,
  PERSISTENT: 3,
});

/** HistoryKind matching the Idris2 ABI tags. */
export const HistoryKind = Object.freeze({
  KEEP_LAST: 0,
  KEEP_ALL: 1,
});

/** OwnershipKind matching the Idris2 ABI tags. */
export const OwnershipKind = Object.freeze({
  SHARED: 0,
  EXCLUSIVE: 1,
});

/** EntityType matching the Idris2 ABI tags. */
export const EntityType = Object.freeze({
  PARTICIPANT: 0,
  PUBLISHER: 1,
  SUBSCRIBER: 2,
  TOPIC: 3,
  DATA_WRITER: 4,
  DATA_READER: 5,
});

/** ParticipantState matching the Idris2 ABI tags. */
export const ParticipantState = Object.freeze({
  IDLE: 0,
  JOINED: 1,
  PUBLISHING: 2,
  SUBSCRIBING: 3,
  LEAVING: 4,
});
