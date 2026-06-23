-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| The timestamp-authority abstraction.
|||
||| A `TimestampProvider` decides the `timestamp_source` recorded on a
||| receipt and (in future) supplies an external proof token.  v1 ships only
||| the internal provider; the RFC 3161 and anchoring providers are stubbed
||| with a clear plug-in point so they can be added without touching the
||| receipt format or the chain logic.
module Timestamp.Provider

import Timestamp.Types

%default total

||| Abstract timestamp authority.
public export
record TimestampProvider where
  constructor MkTimestampProvider
  providerName   : String
  providerSource : TimestampSource

||| The built-in, non-qualified provider used by default in v1.
public export
internalProvider : TimestampProvider
internalProvider = MkTimestampProvider "internal" Internal

-- TODO(rfc3161): add a real external provider, e.g.
--
--   export
--   rfc3161Provider : (tsaUrl : String) -> TimestampProvider
--   rfc3161Provider _ = MkTimestampProvider "rfc3161" Rfc3161
--
-- Its runtime would POST an RFC 3161 TimeStampReq (DER) to `tsaUrl`, embed
-- the returned TimeStampToken in the receipt's `server_signature`, and set
-- `timestamp_source = rfc3161`.  Wire it in at `ts_append` in the Zig engine
-- (where the source byte is chosen) and at provider selection in the HTTP
-- layer.  The pre-image and chain proofs are unaffected: only the source
-- name and the (currently reserved) signature field change.

-- TODO(anchored): an `anchoredProvider` could periodically publish the head
-- receipt_hash to an external transparency log / ledger and record the
-- anchor, giving `timestamp_source = anchored`.
