// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDP protocol types for proven-servers.

/** ContainerType matching the Idris2 ABI tags. */
export const ContainerType = Object.freeze({
  BASIC: 0,
  DIRECT: 1,
  INDIRECT: 2,
});

/** LdpResourceType matching the Idris2 ABI tags. */
export const LdpResourceType = Object.freeze({
  RDF_SOURCE: 0,
  NON_RDF_SOURCE: 1,
  CONTAINER: 2,
});

/** Preference matching the Idris2 ABI tags. */
export const Preference = Object.freeze({
  MINIMAL_CONTAINER: 0,
  INCLUDE_CONTAINMENT: 1,
  INCLUDE_MEMBERSHIP: 2,
  OMIT_CONTAINMENT: 3,
  OMIT_MEMBERSHIP: 4,
});

/** InteractionModel matching the Idris2 ABI tags. */
export const InteractionModel = Object.freeze({
  LDPR: 0,
  LDPC: 1,
  LDP_BASIC_CONTAINER: 2,
  LDP_DIRECT_CONTAINER: 3,
  LDP_INDIRECT_CONTAINER: 4,
});

/** ConstraintViolation matching the Idris2 ABI tags. */
export const ConstraintViolation = Object.freeze({
  MEMBERSHIP_CONSTANT: 0,
  CONTAINS_TRIPLES_MODIFIED: 1,
  SERVER_MANAGED: 2,
  TYPE_CONFLICT: 3,
});
