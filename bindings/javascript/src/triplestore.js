// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Triplestore protocol types for proven-servers.

/** Statement matching the Idris2 ABI tags. */
export const Statement = Object.freeze({
  TRIPLE: 0,
  QUAD: 1,
});

/** IndexOrder matching the Idris2 ABI tags. */
export const IndexOrder = Object.freeze({
  SPO: 0,
  POS: 1,
  OSP: 2,
  GSPO: 3,
  GPOS: 4,
  GOSP: 5,
});

/** StorageBackend matching the Idris2 ABI tags. */
export const StorageBackend = Object.freeze({
  IN_MEMORY: 0,
  B_TREE: 1,
  LSM: 2,
  PERSISTENT: 3,
});

/** ImportFormat matching the Idris2 ABI tags. */
export const ImportFormat = Object.freeze({
  N_TRIPLES: 0,
  TURTLE: 1,
  RDF_XML: 2,
  JSON_LD: 3,
  N_QUADS: 4,
  TRIG: 5,
});

/** TransactionIsolation matching the Idris2 ABI tags. */
export const TransactionIsolation = Object.freeze({
  READ_COMMITTED: 0,
  SERIALIZABLE: 1,
  SNAPSHOT: 2,
});

/** StoreState matching the Idris2 ABI tags. */
export const StoreState = Object.freeze({
  IDLE: 0,
  READY: 1,
  IN_TRANSACTION: 2,
  IMPORTING: 3,
  CLOSING: 4,
});
