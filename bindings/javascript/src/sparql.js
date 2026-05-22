// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL protocol types for proven-servers.

/** SparqlQueryType matching the Idris2 ABI tags. */
export const SparqlQueryType = Object.freeze({
  SELECT: 0,
  CONSTRUCT: 1,
  ASK: 2,
  DESCRIBE: 3,
});

/** UpdateType matching the Idris2 ABI tags. */
export const UpdateType = Object.freeze({
  INSERT: 0,
  DELETE: 1,
  LOAD: 2,
  CLEAR: 3,
  CREATE: 4,
  DROP: 5,
});

/** ResultFormat matching the Idris2 ABI tags. */
export const ResultFormat = Object.freeze({
  XML: 0,
  JSON: 1,
  CSV: 2,
  TSV: 3,
});

/** SparqlErrorType matching the Idris2 ABI tags. */
export const SparqlErrorType = Object.freeze({
  PARSE_ERROR: 0,
  QUERY_TIMEOUT: 1,
  RESULTS_TOO_LARGE: 2,
  UNKNOWN_GRAPH: 3,
  ACCESS_DENIED: 4,
});
