// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for proven-servers.

/** Command matching the Idris2 ABI tags. */
export const Command = Object.freeze({
  GET: 0,
  SET: 1,
  DELETE: 2,
  EXISTS: 3,
  EXPIRE: 4,
  TTL: 5,
  KEYS: 6,
  FLUSH: 7,
  INCR: 8,
  DECR: 9,
  APPEND: 10,
  PREPEND: 11,
  CAS: 12,
});

/** EvictionPolicy matching the Idris2 ABI tags. */
export const EvictionPolicy = Object.freeze({
  LRU: 0,
  LFU: 1,
  RANDOM: 2,
  EVICT_TTL: 3,
  NO_EVICTION: 4,
});

/** DataType matching the Idris2 ABI tags. */
export const DataType = Object.freeze({
  STRING_VAL: 0,
  INT_VAL: 1,
  LIST_VAL: 2,
  SET_VAL: 3,
  HASH_VAL: 4,
});

/** ErrorCode matching the Idris2 ABI tags. */
export const ErrorCode = Object.freeze({
  NOT_FOUND: 0,
  TYPE_MISMATCH: 1,
  OUT_OF_MEMORY: 2,
  KEY_TOO_LONG: 3,
  VALUE_TOO_LARGE: 4,
  CAS_CONFLICT: 5,
});

/** ReplicationMode matching the Idris2 ABI tags. */
export const ReplicationMode = Object.freeze({
  NONE: 0,
  PRIMARY: 1,
  REPLICA: 2,
  SENTINEL: 3,
});
