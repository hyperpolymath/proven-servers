// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// mDNS protocol types for proven-servers.

/** MdnsRecordType matching the Idris2 ABI tags. */
export const MdnsRecordType = Object.freeze({
  A: 0,
  AAAA: 1,
  PTR: 2,
  SRV: 3,
  TXT: 4,
});

/** QueryType matching the Idris2 ABI tags. */
export const QueryType = Object.freeze({
  STANDARD: 0,
  ONE_SHOT: 1,
  CONTINUOUS: 2,
});

/** ConflictAction matching the Idris2 ABI tags. */
export const ConflictAction = Object.freeze({
  PROBE: 0,
  DEFEND: 1,
  WITHDRAW: 2,
});

/** ServiceFlag matching the Idris2 ABI tags. */
export const ServiceFlag = Object.freeze({
  UNIQUE: 0,
  SHARED: 1,
});

/** ResponderState matching the Idris2 ABI tags. */
export const ResponderState = Object.freeze({
  IDLE: 0,
  PROBING: 1,
  ANNOUNCING: 2,
  RUNNING: 3,
  SHUTTING_DOWN: 4,
});
